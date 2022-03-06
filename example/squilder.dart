library squilder.example;

import 'package:squilder/squilder.dart';

class OrderTable extends Table {
  String get name => "orders";

  late final OrderTableFields f;

  TableField<int> get primaryKey => f.id;

  OrderTable() {
    f = OrderTableFields(this);
  }
}

class OrderTableFields extends TableFields {
  final TableField<int> id;
  final TableField<String> name;

  Iterable<TableField> get all => [id, name];

  OrderTableFields(Table table)
      : id = TableField(table, "id"),
        name = TableField(table, "name");
}

void main() {
  final orders = new OrderTable();
  final sql = select(orders.f.all)
      .from([orders])
      .where(orders.f.id.eqToObj(5).and(orders.f.name.like("%blah%")))
      .toSql();
  var a = select(orders.f.all).where(orders.f.id.eqToObj(5));
  final sql2 = select(orders.f.all)
      .where(orders.f.id.eqToObj(5).and(orders.f.name.like("%blah%")))
      .toSql();
  print(a);
  print(sql);
  print(sql2);
}
