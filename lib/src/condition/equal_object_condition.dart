part of squilder.condition;

class EqualObjectCondition<T> with Condition {
  final TableField<T> field;
  final T object;

  EqualObjectCondition(this.field, this.object);

  String toSql() {
    return "${field.toSql()} = ${utils.objectToSql(object)}";
  }
}

