// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library squilder.test;

import 'package:squilder/squilder.dart';
import 'package:test/test.dart';

class OrderTable extends Table {
  String get name => "orders";

  late final OrderTableFields _f;

  OrderTableFields get f => _f;

  TableField<int> get primaryKey => f.id;

  OrderTable() {
    _f = new OrderTableFields(this);
  }
}

final orders = new OrderTable();

class OrderTableFields extends TableFields {
  late final TableField<int> _id;

  TableField<int> get id => _id;

  late final TableField<String> _name;

  TableField<String> get name => _name;

  Iterable<TableField> get all => [id, name];

  OrderTableFields(Table table) {
    _id = new TableField<int>(table, "id");
    _name = new TableField<String>(table, "name");
  }
}

class OrderRecipientsTable extends Table {
  String get name => "order_recipients";

  late final OrderRecipientsFields f;

  TableField<int> get primaryKey => f.id;

  OrderRecipientsTable() {
    f = new OrderRecipientsFields(this);
  }
}

final orderRecipients = new OrderRecipientsTable();

class OrderRecipientsFields extends TableFields {
  late final TableField<int> id;

  late final TableField<String> name;

  late final TableField<int> orderId;

  Iterable<TableField> get all => [id, name, orderId];

  OrderRecipientsFields(Table table) {
    id = TableField<int>(table, "id");
    name = TableField<String>(table, "name");
    orderId = TableField<int>(table, "order_id");
  }
}

void main() {
  group('A group of tests', () {
    setUp(() {});

    test('select Test', () {
      String sql = select(orders.f.all)
          .from([orders])
          .innerJoin(orderRecipients)
          .on(orders.f.id.eqToField(orderRecipients.f.orderId))
          .where(orders.f.id.eqToObj(5).and(orders.f.name.like("%blah%")))
          .union(
              select(orders.f.all).from([orders]).where(orders.f.id.eqToObj(6)))
          .toSql();
      print(sql);
      expect(true, isTrue);
    });

    test('insertInto Test', () {
      String sql = insertInto(orderRecipients,
              [orderRecipients.f.name, orderRecipients.f.orderId])
          .values(["new", 5])
          .onDuplicateKeyUpdate()
          .setObj(orderRecipients.f.name, "default")
          .setObj(orderRecipients.f.orderId, 6)
          .toSql();
      print(sql);
      expect(true, isTrue);
    });

    test('update Test', () {
      String sql = update(orderRecipients)
          .setObj(orderRecipients.f.name, "default")
          .setObj(orderRecipients.f.orderId, 6)
          .where(orderRecipients.f.name.eqToObj("blah"))
          .toSql();
      print(sql);
      expect(true, isTrue);
    });

    test('delete Test', () {
      String sql = delete(orderRecipients)
          .where(orderRecipients.f.name.eqToObj("blah"))
          .toSql();
      print(sql);
      expect(true, isTrue);
    });
  });
}
