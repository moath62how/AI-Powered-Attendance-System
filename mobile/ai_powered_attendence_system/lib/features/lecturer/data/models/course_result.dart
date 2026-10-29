//! Course Result

sealed class CourseResult<T> {
  const CourseResult();
}

class CourseSuccess<T> extends CourseResult<T> {
  final T data;
  const CourseSuccess(this.data);
}

class CourseFailure<T> extends CourseResult<T> {
  final String message;
  final int? statusCode;
  const CourseFailure(this.message, {this.statusCode});
}

