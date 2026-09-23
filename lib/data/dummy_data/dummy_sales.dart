import '../models/sales_data.dart';

/// TEMPORARY PLACEHOLDER DATA — see dummy_products.dart for context.
/// Replace with real sales data from a backend before shipping.

/// One category's share of revenue, used by the Owner analytics screens.
class CategoryRevenue {
  final String categoryId;
  final double revenue;
  final double marginPercent;

  const CategoryRevenue({
    required this.categoryId,
    required this.revenue,
    required this.marginPercent,
  });
}

/// One week's performance snapshot, used by the Sales Trends breakdown.
class WeeklyBreakdown {
  final String label; // e.g. "W1"
  final String dateRange; // e.g. "Sep 1 - Sep 7"
  final int orders;
  final double revenue;
  final double growthPercent;

  const WeeklyBreakdown({
    required this.label,
    required this.dateRange,
    required this.orders,
    required this.revenue,
    required this.growthPercent,
  });
}

const List<BranchSales> kBranchSalesList = [
  BranchSales(
    branch: 'Santa Cruz Main',
    todayRevenue: 18500,
    weekRevenue: 112000,
    monthRevenue: 462000,
    ordersToday: 64,
    ordersWeek: 398,
    yoyGrowthPercent: 12.4,
    stockHealthPercent: 91.2,
    topPerformer: 'Rosa Villamor',
    leadContact: '+63 917 123 4567',
  ),
  BranchSales(
    branch: 'Calamba Branch',
    todayRevenue: 14200,
    weekRevenue: 89500,
    monthRevenue: 371000,
    ordersToday: 51,
    ordersWeek: 312,
    yoyGrowthPercent: 8.1,
    stockHealthPercent: 87.6,
    topPerformer: 'Mark Untalan',
    leadContact: '+63 917 234 5678',
  ),
  BranchSales(
    branch: 'Los Baños Hub',
    todayRevenue: 9800,
    weekRevenue: 61200,
    monthRevenue: 256500,
    ordersToday: 33,
    ordersWeek: 214,
    yoyGrowthPercent: 15.7,
    stockHealthPercent: 94.0,
    topPerformer: 'Jenny Pascual',
    leadContact: '+63 917 345 6789',
  ),
];

double get todaysGrossSales =>
    kBranchSalesList.fold<double>(0, (sum, b) => sum + b.todayRevenue);

int get todaysOrderCount =>
    kBranchSalesList.fold<int>(0, (sum, b) => sum + b.ordersToday);

double get weekGrossSales =>
    kBranchSalesList.fold<double>(0, (sum, b) => sum + b.weekRevenue);

int get weekOrderCount =>
    kBranchSalesList.fold<int>(0, (sum, b) => sum + b.ordersWeek);

double get monthGrossSales =>
    kBranchSalesList.fold<double>(0, (sum, b) => sum + b.monthRevenue);

BranchSales findBranchSales(String branch) {
  return kBranchSalesList.firstWhere(
    (b) => b.branch == branch,
    orElse: () => kBranchSalesList.first,
  );
}

final List<CategoryRevenue> categoryRevenueBreakdown = [
  const CategoryRevenue(categoryId: 'classic', revenue: 168000, marginPercent: 52.1),
  const CategoryRevenue(categoryId: 'garlic', revenue: 142500, marginPercent: 50.8),
  const CategoryRevenue(categoryId: 'sweet', revenue: 98200, marginPercent: 48.3),
  const CategoryRevenue(categoryId: 'spicy', revenue: 53800, marginPercent: 51.5),
];

const List<RevenuePoint> kWeeklyRevenueSeries = [
  RevenuePoint('Mon', 15200),
  RevenuePoint('Tue', 16800),
  RevenuePoint('Wed', 14500),
  RevenuePoint('Thu', 17900),
  RevenuePoint('Fri', 19400),
  RevenuePoint('Sat', 24300),
  RevenuePoint('Sun', 21400),
];

const List<RevenuePoint> kMonthlyRevenueSeries = [
  RevenuePoint('May', 372000),
  RevenuePoint('Jun', 388000),
  RevenuePoint('Jul', 401000),
  RevenuePoint('Aug', 419500),
  RevenuePoint('Sep', 462000),
];

const List<WeeklyBreakdown> kWeeklyBreakdown = [
  WeeklyBreakdown(label: 'W4', dateRange: 'Sep 15 - Sep 21', orders: 412, revenue: 129500, growthPercent: 5.4),
  WeeklyBreakdown(label: 'W3', dateRange: 'Sep 8 - Sep 14', orders: 389, revenue: 122900, growthPercent: 3.1),
  WeeklyBreakdown(label: 'W2', dateRange: 'Sep 1 - Sep 7', orders: 356, revenue: 119200, growthPercent: -1.2),
  WeeklyBreakdown(label: 'W1', dateRange: 'Aug 25 - Aug 31', orders: 371, revenue: 120600, growthPercent: 0),
];

// --- Sales Forecast (simulated simple linear regression) -----------------

const double kForecastNextMonthTotal = 498000;
const double kForecastRangeLow = 462000;
const double kForecastRangeHigh = 534000;
const double kForecastConfidenceR2 = 0.87;
const double kForecastGrowthPercent = 7.8;

const List<RevenuePoint> kForecastTrajectory = [
  RevenuePoint('Oct', 483000, isProjection: true),
  RevenuePoint('Nov', 498000, isProjection: true),
];

const List<RestockInsight> kRestockInsights = [
  RestockInsight(
    branch: 'Santa Cruz Main',
    productName: 'Garlic Peanuts',
    note: 'Selling faster than usual this month.',
    currentWeeklyRun: 140,
    projectedDemand: 175,
    growthPercent: 25,
    recommendation: 'Restock 60 units before next weekend.',
  ),
  RestockInsight(
    branch: 'Calamba Branch',
    productName: 'Honey Glazed Peanuts',
    note: 'Steady demand, batch running low.',
    currentWeeklyRun: 95,
    projectedDemand: 100,
    growthPercent: 5,
    recommendation: 'Restock 30 units this week.',
  ),
  RestockInsight(
    branch: 'Los Baños Hub',
    productName: 'Chili Garlic Peanuts',
    note: 'Low stock with rising demand.',
    currentWeeklyRun: 60,
    projectedDemand: 82,
    growthPercent: 37,
    recommendation: 'Restock 40 units before next weekend.',
  ),
];
