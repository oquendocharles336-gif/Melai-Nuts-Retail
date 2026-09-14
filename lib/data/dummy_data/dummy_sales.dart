import '../models/sales_data.dart';
import 'dummy_products.dart';

/// Static, dummy aggregated sales data for the Owner module. No backend —
/// all figures here are for frontend preview only.

const List<BranchSales> kBranchSalesList = [
  BranchSales(
    branch: 'Calamba Highway Branch',
    todayRevenue: 21450,
    weekRevenue: 148200,
    monthRevenue: 612000,
    ordersToday: 58,
    ordersWeek: 392,
    yoyGrowthPercent: 18.5,
    stockHealthPercent: 98.4,
    topPerformer: 'Paolo Reyes',
    leadContact: '(049) 545-2981',
  ),
  BranchSales(
    branch: 'Los Baños Hub',
    todayRevenue: 18220,
    weekRevenue: 126400,
    monthRevenue: 528500,
    ordersToday: 52,
    ordersWeek: 341,
    yoyGrowthPercent: 9.2,
    stockHealthPercent: 94.1,
    topPerformer: 'Gina Lopez',
    leadContact: '(049) 501-2210',
  ),
  BranchSales(
    branch: 'Santa Cruz Flagship',
    todayRevenue: 13170,
    weekRevenue: 97150,
    monthRevenue: 401200,
    ordersToday: 38,
    ordersWeek: 248,
    yoyGrowthPercent: 6.4,
    stockHealthPercent: 100,
    topPerformer: 'Mario Santos',
    leadContact: '(049) 536-4471',
  ),
];

double get todaysGrossSales => kBranchSalesList.fold(0, (sum, b) => sum + b.todayRevenue);
double get weekGrossSales => kBranchSalesList.fold(0, (sum, b) => sum + b.weekRevenue);
double get monthGrossSales => kBranchSalesList.fold(0, (sum, b) => sum + b.monthRevenue);
int get todaysOrderCount => kBranchSalesList.fold(0, (sum, b) => sum + b.ordersToday);
int get weekOrderCount => kBranchSalesList.fold(0, (sum, b) => sum + b.ordersWeek);

/// Last 7 days of combined (all-branch) daily revenue — matches the
/// prototype's "7-Day Sales Trend" / "Weekly In-Store Influx" charts.
const List<RevenuePoint> kWeeklyRevenueSeries = [
  RevenuePoint('M', 14000),
  RevenuePoint('T', 12500),
  RevenuePoint('W', 15200),
  RevenuePoint('T', 16800),
  RevenuePoint('F', 21400),
  RevenuePoint('S', 26500),
  RevenuePoint('S', 22000),
];

/// Last 6 months of combined monthly revenue, for the Trends screen's
/// "Monthly" tab.
const List<RevenuePoint> kMonthlyRevenueSeries = [
  RevenuePoint('Apr', 402000),
  RevenuePoint('May', 418500),
  RevenuePoint('Jun', 445000),
  RevenuePoint('Jul', 461200),
  RevenuePoint('Aug', 483700),
  RevenuePoint('Sep', 495800),
];

/// Weekly aggregate breakdown (past 4 weeks) — matches the prototype's
/// "Performance Breakdown" list on the Sales Trends screen.
const List<({String label, String dateRange, double revenue, int orders, double growthPercent})> kWeeklyBreakdown = [
  (label: 'W4', dateRange: 'This Week', revenue: 128450, orders: 540, growthPercent: 9.2),
  (label: 'W3', dateRange: 'Last Week', revenue: 117600, orders: 495, growthPercent: 6.4),
  (label: 'W2', dateRange: '2 Weeks Ago', revenue: 110500, orders: 470, growthPercent: 3.1),
  (label: 'W1', dateRange: '3 Weeks Ago', revenue: 107200, orders: 455, growthPercent: 0.0),
];

/// Simulated linear-regression sales forecast for the next 4 weeks.
/// See [RestockInsight] for per-branch restocking guidance derived from it.
/// All figures here are explicitly labeled as *estimates* in the UI.
const double kForecastNextMonthTotal = 565000;
const double kForecastRangeLow = 535000;
const double kForecastRangeHigh = 595000;
const double kForecastGrowthPercent = 14.2;
const double kForecastConfidenceR2 = 0.89;

const List<RevenuePoint> kForecastTrajectory = [
  RevenuePoint('W9', 134000, isProjection: true),
  RevenuePoint('W10', 139000, isProjection: true),
  RevenuePoint('W11', 144000, isProjection: true),
  RevenuePoint('W12', 148000, isProjection: true),
];

const List<RestockInsight> kRestockInsights = [
  RestockInsight(
    branch: 'Santa Cruz Flagship',
    productName: 'Garlic Peanuts (250g Pouch)',
    note: 'Garlic Peanuts are showing an increasing sales trend. Consider increasing next week\'s stock.',
    currentWeeklyRun: 210,
    projectedDemand: 260,
    growthPercent: 23.8,
    recommendation: 'Recommended roasting buffer: +50 packs at Santa Cruz Master Roastery.',
  ),
  RestockInsight(
    branch: 'Calamba Highway Branch',
    productName: 'Family Pasalubong Box (4-Pack)',
    note: 'Holiday and long weekend travel approaching. Tourist highway stop orders are projected to increase by 18%.',
    currentWeeklyRun: 190,
    projectedDemand: 224,
    growthPercent: 18.0,
    recommendation: 'Action plan: prepare +35 gift crates before Friday afternoon dispatch.',
  ),
  RestockInsight(
    branch: 'Los Baños Hub',
    productName: 'Spicy Skinless Peanuts (250g)',
    note: 'Student exam week demand spike expected at Los Baños Hub.',
    currentWeeklyRun: 150,
    projectedDemand: 180,
    growthPercent: 20.0,
    recommendation: 'Maintain a safety floor of 40 units before Wednesday\'s restock run.',
  ),
];

/// Category revenue breakdown derived at runtime from [kProducts], so it
/// never drifts out of sync with the product catalog.
List<({String categoryId, double revenue, double marginPercent})> get categoryRevenueBreakdown {
  final byCategory = <String, List<double>>{};
  final marginByCategory = <String, List<double>>{};
  for (final p in kProducts) {
    byCategory.putIfAbsent(p.categoryId, () => []).add(p.monthlyRevenue);
    marginByCategory.putIfAbsent(p.categoryId, () => []).add(p.marginPercent);
  }
  return [
    for (final entry in byCategory.entries)
      (
        categoryId: entry.key,
        revenue: entry.value.fold(0.0, (a, b) => a + b),
        marginPercent: marginByCategory[entry.key]!.fold(0.0, (a, b) => a + b) / marginByCategory[entry.key]!.length,
      ),
  ];
}

BranchSales findBranchSales(String branch) => kBranchSalesList.firstWhere(
      (b) => b.branch == branch,
      orElse: () => kBranchSalesList.first,
    );
