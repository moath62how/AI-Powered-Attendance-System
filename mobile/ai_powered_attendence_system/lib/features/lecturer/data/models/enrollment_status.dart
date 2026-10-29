//! Enrollment Status Enum

enum EnrollmentStatus { open, closed }

extension EnrollmentStatusExtension on EnrollmentStatus {
  String get label => this == EnrollmentStatus.open ? 'Open' : 'Closed';

  String get description => this == EnrollmentStatus.open
      ? 'Students are accepted automatically.'
      : 'No New Students are accepted.';

  String toBackendMode() =>
      this == EnrollmentStatus.open ? 'AutoApprove' : 'Closed';

  static EnrollmentStatus fromBackend(String mode) {
    return mode.toLowerCase() == 'autoapprove'
        ? EnrollmentStatus.open
        : EnrollmentStatus.closed;
  }
}

