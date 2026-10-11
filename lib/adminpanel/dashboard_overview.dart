import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// --- DATA MODELS ---
class DashboardData {
  final int totalUsers;
  final int totalOrders;
  final double totalRevenue;

  DashboardData(
      {required this.totalUsers,
      required this.totalOrders,
      required this.totalRevenue});
}

class UserGrowthData {
  final DateTime date;
  final int count;
  UserGrowthData(this.date, this.count);
}

class RevenueTrendData {
  final DateTime date;
  final double revenue;
  RevenueTrendData(this.date, this.revenue);
}

class OrderStatusData {
  final String status;
  final int count;
  OrderStatusData(this.status, this.count);
}

class TopProductData {
  final String productName;
  final int sales;
  TopProductData(this.productName, this.sales);
}

class ActiveUserData {
  final String day;
  final int count;
  ActiveUserData(this.day, this.count);
}

// --- MAIN WIDGET ---
class DashboardOverview extends StatefulWidget {
  const DashboardOverview({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardOverviewState createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview> {
  late Future<DashboardData> _dashboardDataFuture;

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _fetchDashboardData();
  }

  Future<DashboardData> _fetchDashboardData() async {
    final db = FirebaseFirestore.instance;

    QuerySnapshot userSnap = await db.collection('users').get();
    QuerySnapshot ordersSnap = await db.collection('ShippingInformation').get();

    int totalUsers = userSnap.docs.length;
    int totalOrders = ordersSnap.docs.length;
    double totalRevenue = 0.0;

    Future<void> processProductCollection(String collectionName) async {
      QuerySnapshot productSnap = await db.collection(collectionName).get();
      for (var doc in productSnap.docs) {
        double price;
        if (doc['price'] is int) {
          price = (doc['price'] as int).toDouble();
        } else if (doc['price'] is double) {
          price = doc['price'];
        } else {
          price = double.tryParse(doc['price'].toString()) ?? 0.0;
        }
        totalRevenue += price;
      }
    }

    await processProductCollection('recommended');
    await processProductCollection('newArrivals');
    await processProductCollection('deals');

    return DashboardData(
        totalUsers: totalUsers,
        totalOrders: totalOrders,
        totalRevenue: totalRevenue);
  }

  // Modernized Metric Card (Responsive Web Design)
  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: 250, // Fixed width for wrap layout
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000033))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CHARTS ---
  Widget _buildUserGrowthChart() {
    final List<UserGrowthData> chartData = [
      UserGrowthData(DateTime(2023, 4, 1), 50),
      UserGrowthData(DateTime(2023, 5, 1), 75),
      UserGrowthData(DateTime(2023, 6, 1), 100),
      UserGrowthData(DateTime(2023, 7, 1), 150),
      UserGrowthData(DateTime(2023, 8, 1), 200),
    ];

    return _chartCardContainer(
      child: SfCartesianChart(
        title: ChartTitle(
            text: 'User Growth',
            textStyle: const TextStyle(fontWeight: FontWeight.bold)),
        primaryXAxis: DateTimeAxis(
            dateFormat: DateFormat.MMM(),
            intervalType: DateTimeIntervalType.months,
            majorGridLines: const MajorGridLines(width: 0)),
        primaryYAxis: NumericAxis(
            majorGridLines: MajorGridLines(color: Colors.grey.shade100)),
        series: <StackedAreaSeries<UserGrowthData, DateTime>>[
          StackedAreaSeries<UserGrowthData, DateTime>(
            dataSource: chartData,
            xValueMapper: (UserGrowthData data, _) => data.date,
            yValueMapper: (UserGrowthData data, _) => data.count,
            color: const Color(0xFF000033).withValues(alpha: 0.8),
            markerSettings: const MarkerSettings(
                isVisible: true,
                color: Colors.white,
                borderColor: Color(0xFF000033)),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTrendChart() {
    final List<RevenueTrendData> chartData = [
      RevenueTrendData(DateTime(2023, 4, 1), 1000),
      RevenueTrendData(DateTime(2023, 4, 10), 1200),
      RevenueTrendData(DateTime(2023, 4, 20), 1500),
      RevenueTrendData(DateTime(2023, 5, 1), 1800),
      RevenueTrendData(DateTime(2023, 5, 10), 1600),
      RevenueTrendData(DateTime(2023, 5, 20), 1900),
      RevenueTrendData(DateTime(2023, 6, 1), 2200),
      RevenueTrendData(DateTime(2023, 6, 10), 2500),
      RevenueTrendData(DateTime(2023, 6, 20), 2100),
      RevenueTrendData(DateTime(2023, 7, 1), 2400),
      RevenueTrendData(DateTime(2023, 7, 10), 2600),
      RevenueTrendData(DateTime(2023, 7, 20), 3000),
      RevenueTrendData(DateTime(2023, 8, 1), 2800),
    ];

    return _chartCardContainer(
      child: SfCartesianChart(
        title: ChartTitle(
            text: 'Revenue Trend',
            textStyle: const TextStyle(fontWeight: FontWeight.bold)),
        primaryXAxis: DateTimeAxis(
            dateFormat: DateFormat.MMM(),
            intervalType: DateTimeIntervalType.days,
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            majorGridLines: const MajorGridLines(width: 0)),
        primaryYAxis: NumericAxis(
            numberFormat: NumberFormat.simpleCurrency(),
            majorGridLines: MajorGridLines(color: Colors.grey.shade100)),
        zoomPanBehavior: ZoomPanBehavior(
            enablePinching: true, enablePanning: true, zoomMode: ZoomMode.x),
        trackballBehavior: TrackballBehavior(
            enable: true,
            activationMode: ActivationMode.singleTap,
            lineColor: Colors.green,
            lineWidth: 2,
            tooltipSettings: const InteractiveTooltip(enable: true)),
        series: <SplineAreaSeries<RevenueTrendData, DateTime>>[
          SplineAreaSeries<RevenueTrendData, DateTime>(
            dataSource: chartData,
            xValueMapper: (RevenueTrendData data, _) => data.date,
            yValueMapper: (RevenueTrendData data, _) => data.revenue,
            gradient: LinearGradient(colors: [
              Colors.green.shade400.withValues(alpha: 0.6),
              Colors.green.shade100.withValues(alpha: 0.1)
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderColor: Colors.green,
            borderWidth: 2,
            markerSettings: const MarkerSettings(
                isVisible: true,
                color: Colors.white,
                borderColor: Colors.green),
          )
        ],
      ),
    );
  }

  Widget _buildOrdersOverviewChart() {
    final List<OrderStatusData> chartData = [
      OrderStatusData('Pending', 5),
      OrderStatusData('Shipped', 8),
      OrderStatusData('Delivered', 12),
    ];

    return _chartCardContainer(
      child: SfCircularChart(
        title: ChartTitle(
            text: 'Orders Overview',
            textStyle: const TextStyle(fontWeight: FontWeight.bold)),
        legend: Legend(
            isVisible: true,
            overflowMode: LegendItemOverflowMode.wrap,
            position: LegendPosition.bottom),
        palette: const [Colors.orange, Colors.purple, Colors.green],
        series: <DoughnutSeries<OrderStatusData, String>>[
          DoughnutSeries<OrderStatusData, String>(
            dataSource: chartData,
            xValueMapper: (OrderStatusData data, _) => data.status,
            yValueMapper: (OrderStatusData data, _) => data.count,
            dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            radius: '80%',
            innerRadius: '50%',
          )
        ],
      ),
    );
  }

  Widget _buildTopProductsChart() {
    final List<TopProductData> chartData = [
      TopProductData('Product A', 30),
      TopProductData('Product B', 45),
      TopProductData('Product C', 25),
      TopProductData('Product D', 50),
    ];

    return _chartCardContainer(
      child: SfCartesianChart(
        title: ChartTitle(
            text: 'Top Products',
            textStyle: const TextStyle(fontWeight: FontWeight.bold)),
        primaryXAxis: CategoryAxis(
            majorGridLines: const MajorGridLines(width: 0), labelRotation: 0),
        primaryYAxis: NumericAxis(
            majorGridLines: MajorGridLines(color: Colors.grey.shade100)),
        series: <ColumnSeries<TopProductData, String>>[
          ColumnSeries<TopProductData, String>(
            dataSource: chartData,
            xValueMapper: (TopProductData data, _) => data.productName,
            yValueMapper: (TopProductData data, _) => data.sales,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            color: Colors.blueAccent,
            dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // Wrapper container for all charts to ensure consistent white cards
  Widget _chartCardContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardData>(
      future: _dashboardDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF000033)));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Dashboard Overview",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000033))),
                const SizedBox(height: 24),

                // Responsive top metric cards
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildMetricCard('Total Users', data.totalUsers.toString(),
                        Icons.people_outline, Colors.blue),
                    _buildMetricCard(
                        'Total Orders',
                        data.totalOrders.toString(),
                        Icons.local_shipping_outlined,
                        Colors.purple),
                    _buildMetricCard(
                        'Total Revenue',
                        '\$${data.totalRevenue.toStringAsFixed(2)}',
                        Icons.attach_money,
                        Colors.green),
                  ],
                ),
                const SizedBox(height: 32),

                // Responsive Chart Grid
                LayoutBuilder(builder: (context, constraints) {
                  bool isWide = constraints.maxWidth > 800;
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildRevenueTrendChart()),
                          if (isWide) ...[
                            const SizedBox(width: 24),
                            Expanded(child: _buildUserGrowthChart()),
                          ]
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (!isWide) ...[
                        _buildUserGrowthChart(),
                        const SizedBox(height: 24),
                      ],
                      Row(
                        children: [
                          Expanded(child: _buildTopProductsChart()),
                          if (isWide) ...[
                            const SizedBox(width: 24),
                            Expanded(child: _buildOrdersOverviewChart()),
                          ]
                        ],
                      ),
                      if (!isWide) ...[
                        const SizedBox(height: 24),
                        _buildOrdersOverviewChart(),
                      ]
                    ],
                  );
                }),
                const SizedBox(height: 40),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}
