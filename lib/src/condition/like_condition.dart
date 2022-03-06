part of squilder.condition;

class LikeCondition with Condition {
  final TableField field;
  final String pattern;

  LikeCondition(this.field, this.pattern);

  String toSql() => "${field.toSql()} LIKE ${utils.objectToSql(pattern)}";
}
