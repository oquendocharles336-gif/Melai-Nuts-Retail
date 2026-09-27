import '../models/branch.dart';

/// Real branch list — starts empty until [BranchRepository.loadBranches]
/// resolves. Same pattern as `kProducts`: no placeholder branches, since a
/// wrong branch address/phone/hours is actively misleading rather than
/// just incomplete.
final List<Branch> kBranches = <Branch>[];
