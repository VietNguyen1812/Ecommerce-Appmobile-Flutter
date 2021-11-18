import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CircularChartProductRatingWidget extends StatefulWidget {
  final num dem0, dem1, dem2, dem3, dem4, dem5;
  CircularChartProductRatingWidget(
      this.dem0, this.dem1, this.dem2, this.dem3, this.dem4, this.dem5);

  @override
  _CircularChartProductRatingWidgetState createState() =>
      _CircularChartProductRatingWidgetState();
}

class _CircularChartProductRatingWidgetState
    extends State<CircularChartProductRatingWidget> {
  List<GDPData> _chartData;
  TooltipBehavior _tooltipBehavior;

  num tongDem = 0;
  num percentDem0 = 0;
  num percentDem1 = 0;
  num percentDem2 = 0;
  num percentDem3 = 0;
  num percentDem4 = 0;
  num percentDem5 = 0;

  @override
  void initState() {
    this.tongDem = widget.dem0 +
        widget.dem1 +
        widget.dem2 +
        widget.dem3 +
        widget.dem4 +
        widget.dem5;
    this.percentDem0 = (widget.dem0 / this.tongDem) * 100;
    this.percentDem1 = (widget.dem1 / this.tongDem) * 100;
    this.percentDem2 = (widget.dem2 / this.tongDem) * 100;
    this.percentDem3 = (widget.dem3 / this.tongDem) * 100;
    this.percentDem4 = (widget.dem4 / this.tongDem) * 100;
    this.percentDem5 = (widget.dem5 / this.tongDem) * 100;

    _chartData = getChartData();
    _tooltipBehavior = TooltipBehavior(enable: true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      title: ChartTitle(
          text: 'Percentage of Products Star (%)',
          textStyle: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold)),
      legend:
          Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
      tooltipBehavior: _tooltipBehavior,
      series: <CircularSeries>[
        DoughnutSeries<GDPData, String>(
            dataSource: _chartData,
            xValueMapper: (GDPData data, _) => data.continent,
            yValueMapper: (GDPData data, _) => data.gdp,
            dataLabelSettings: DataLabelSettings(isVisible: true),
            enableTooltip: true)
      ],
    );
  }

  List<GDPData> getChartData() {
    final List<GDPData> chartData = [
      this.percentDem0 > 0
          ? GDPData('0 star', roundDouble(this.percentDem0, 1))
          : GDPData('0 star', 0),
      this.percentDem1 > 0
          ? GDPData('1 star', roundDouble(this.percentDem1, 1))
          : GDPData('1 star', 0),
      this.percentDem2 > 0
          ? GDPData('2 stars', roundDouble(this.percentDem2, 1))
          : GDPData('2 stars', 0),
      this.percentDem3 > 0
          ? GDPData('3 stars', roundDouble(this.percentDem3, 1))
          : GDPData('3 stars', 0),
      this.percentDem4 > 0
          ? GDPData('4 stars', roundDouble(this.percentDem4, 1))
          : GDPData('4 stars', 0),
      this.percentDem5 > 0
          ? GDPData('5 stars', roundDouble(this.percentDem5, 1))
          : GDPData('5 stars', 0),
    ];
    return chartData;
  }

  num roundDouble(num value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }
}

class GDPData {
  GDPData(this.continent, this.gdp);
  final String continent;
  final num gdp;
}
