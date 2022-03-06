part of squilder.condition;

class LessObjectCondition<T> with Condition {
  final TableField<T> field;
  final T object;

  LessObjectCondition(this.field, this.object);

  String toSql() => "${field.toSql()} < ${utils.objectToSql(object)}";
}
