import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CartesianChartVendorRevenueWidget extends StatefulWidget {
  final DocumentSnapshot document;
  CartesianChartVendorRevenueWidget(this.document);

  @override
  _CartesianChartVendorRevenueWidgetState createState() =>
      _CartesianChartVendorRevenueWidgetState();
}

class _CartesianChartVendorRevenueWidgetState
    extends State<CartesianChartVendorRevenueWidget> {
  List<_SalesData> _chartData;

  @override
  void initState() {
    _chartData = getChartData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      //Initialize the chart widget
      SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          // Chart title
          title: ChartTitle(
              text: 'Revenue of ${widget.document.data()['shopName']} (\$)',
              textStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold)),
          // Enable legend
          legend: Legend(isVisible: false),
          // Enable tooltip
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ChartSeries<_SalesData, String>>[
            ColumnSeries<_SalesData, String>(
                dataSource: _chartData,
                xValueMapper: (_SalesData sales, _) => sales.year,
                yValueMapper: (_SalesData sales, _) => sales.sales,
                name: 'Dollar \$',
                // Enable data label
                dataLabelSettings: DataLabelSettings(isVisible: false))
          ]),
    ]);
  }

  List<_SalesData> getChartData() {
    final List<_SalesData> chartData = [
      _SalesData(
          'Jan',
          widget.document.data()['revenueShop'] == 0
              ? 0
              : widget.document.data()['revenueShop']['${0}']['revenue'] == 0
                  ? 0
                  : widget.document.data()['revenueShop']['${0}']['revenue']),
      _SalesData(
          'Feb',
          widget.document.data()['revenueShop'] == 0
              ? 0
              : widget.document.data()['revenueShop']['${1}']['revenue'] == 0
                  ? 0
                  : widget.document.data()['revenueShop']['${1}']['revenue']),
      _SalesData(
          'Mar',
          widget.document.data()['revenueShop'] == 0
              ? 0
              : widget.document.data()['revenueShop']['${2}']['revenue'] == 0
                  ? 0
                  : widget.document.data()['revenueShop']['${2}']['revenue']),
      _SalesData(
          'Apr',
          widget.document.data()['revenueShop'] == 0
              ? 0
              : widget.document.data()['revenueShop']['${3}']['revenue'] == 0
                  ? 0
                  : widget.document.data()['revenueShop']['${3}']['revenue']),
      _SalesData(
          'May',
          widget.document.data()['revenueShop'] == 0
              ? 0
              : widget.document.data()['revenueShop']['${4}']['revenue'] == 0
                  ? 0
                  : widget.document.data()['revenueShop']['${4}']['revenue']),
      _SalesData(
          'Jun',
          widget.document.data()['revenueShop'] == 0
              ? 0
              : widget.document.data()['revenueShop']['${5}']['revenue'] == 0
                  ? 0
                  : widget.document.data()['revenueShop']['${5}']['revenue']),
      _SalesData(
          'Jul',
          widget.document.data()['revenueShop'] == 0
              ? 0
              : widget.document.data()['revenueShop']['${6}']['revenue'] == 0
                  ? 0
                  : widget.document.data()['revenueShop']['${6}']['revenue']),
      _SalesData(
          'Aug',
          widget.document.data()['revenueShop'] == 0
              ? 0
              : widget.document.data()['revenueShop']['${7}']['revenue'] == 0
                  ? 0
                  : widget.document.data()['revenueShop']['${7}']['revenue']),
      _SalesData(
          'Sep',
          widget.document.data()['revenueShop'] == 0
              ? 0
              : widget.document.data()['revenueShop']['${8}']['revenue'] == 0
                  ? 0
                  : widget.document.data()['revenueShop']['${8}']['revenue']),
      _SalesData(
          'Oct',
          widget.document.data()['revenueShop'] == 0
              ? 0
              : widget.document.data()['revenueShop']['${9}']['revenue'] == 0
                  ? 0
                  : widget.document.data()['revenueShop']['${9}']['revenue']),
      _SalesData(
          'Nov',
          widget.document.data()['revenueShop'] == 0
              ? 0
              : widget.document.data()['revenueShop']['${10}']['revenue'] == 0
                  ? 0
                  : widget.document.data()['revenueShop']['${10}']['revenue']),
      _SalesData(
          'Dec',
          widget.document.data()['revenueShop'] == 0
              ? 0
              : widget.document.data()['revenueShop']['${11}']['revenue'] == 0
                  ? 0
                  : widget.document.data()['revenueShop']['${11}']['revenue']),
    ];
    return chartData;
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final num sales;
}
