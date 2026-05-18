// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_rudderstack/otel_rudderstack.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_rudderstack-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('batch records source + event types', () async {
    await tracedRudderstack<String>(
      operation: 'batch',
      invoke: () async => const RudderstackCallResult(
        value: 'ok',
        result: RudderstackResult(
          workspaceId: 'ws_1',
          sourceId: 'src_1',
          sourceType: 'flutter',
          deliveryMode: 'cloud',
          batchSize: 250,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('rudderstack batch')!);
    expect(a['rudderstack.source.type'], 'flutter');
    expect(a['rudderstack.delivery.mode'], 'cloud');
    expect(a['rudderstack.batch.size'], 250);
  });

  test('track records event name + destination', () async {
    await tracedRudderstack<String>(
      operation: 'track',
      invoke: () async => const RudderstackCallResult(
        value: 'ok',
        result: RudderstackResult(
          eventType: 'track',
          eventName: 'Order Completed',
          destinationType: 'SNOWFLAKE',
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('rudderstack track')!);
    expect(a['rudderstack.event.type'], 'track');
    expect(a['rudderstack.event.name'], 'Order Completed');
    expect(a['rudderstack.destination.type'], 'SNOWFLAKE');
  });

  test('aborted delivery sets span error', () async {
    await tracedRudderstack<String>(
      operation: 'events.delivery_status',
      invoke: () async => const RudderstackCallResult(
        value: 'ok',
        result: RudderstackResult(
          destinationType: 'WEBHOOK',
          deliveryStatus: 'aborted',
        ),
      ),
    );
    expect(
      spans.findSpanByName('rudderstack events.delivery_status')!.status,
      SpanStatusCode.Error,
    );
  });

  test('filtered transform does NOT set span error', () async {
    await tracedRudderstack<String>(
      operation: 'track',
      invoke: () async => const RudderstackCallResult(
        value: 'ok',
        result: RudderstackResult(
          transformationId: 'tr_1',
          transformationStatus: 'filtered',
        ),
      ),
    );
    expect(
      spans.findSpanByName('rudderstack track')!.status,
      isNot(SpanStatusCode.Error),
    );
  });

  test('suppression skips spans', () async {
    await runWithoutRudderstackInstrumentationAsync(() async {
      await tracedRudderstack<String>(
        operation: 'sources.list',
        invoke: () async => const RudderstackCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('rudderstack '), isEmpty);
  });
}
