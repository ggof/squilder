part of squilder.condition;

class OrConditionPair with Condition {
  final Condition one;
  final Condition two;

  OrConditionPair(this.one, this.two);

  String toSql() => "(${one.toSql()} OR ${two.toSql()})";
}
