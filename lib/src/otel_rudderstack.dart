// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_rudderstack_suppression.dart';

const _tracerName = 'dartastic_otel_libs_rudderstack';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class RudderstackResult {
  /// Creates a result.
  const RudderstackResult({
    this.workspaceId,
    this.sourceId,
    this.sourceType,
    this.writeKey,
    this.destinationId,
    this.destinationType,
    this.eventType,
    this.eventName,
    this.deliveryMode,
    this.transformationId,
    this.transformationStatus,
    this.batchSize,
    this.eventsEvents,
    this.eventsBytes,
    this.deliveryStatus,
    this.statusCode,
  });

  /// RudderStack workspace.
  final String? workspaceId;

  final String? sourceId;

  /// `javascript` / `node` / `python` / `go` / `ruby` / `mobile_ios`
  /// / `mobile_android` / `flutter` / `react-native` / `http` /
  /// `webhook` / `auto-track`.
  final String? sourceType;

  /// Source write key (id only, never the secret).
  final String? writeKey;

  final String? destinationId;

  /// `WEBHOOK` / `GA4` / `BRAZE` / `MIXPANEL` / `AMPLITUDE` /
  /// `FACEBOOK_PIXEL` / `SLACK` / `INTERCOM` / `KAFKA` / `SNOWFLAKE`
  /// / `BIGQUERY` / `S3_DATALAKE` / `POSTGRES` / `WAREHOUSE_*`.
  final String? destinationType;

  /// `track` / `identify` / `page` / `screen` / `group` / `alias` /
  /// `batch`.
  final String? eventType;

  /// Event name (Track/Page/Screen events have a name).
  final String? eventName;

  /// `cloud` (server-side fanout) / `device` (sent directly from the
  /// client SDK).
  final String? deliveryMode;

  /// User transformation id (RudderStack lets you write JS that
  /// transforms events per-destination).
  final String? transformationId;

  /// `success` / `error` / `dropped` / `filtered` — user-transform
  /// outcome.
  final String? transformationStatus;

  /// Number of events posted in this `/batch`.
  final int? batchSize;

  /// Counters when reading aggregations / reports.
  final int? eventsEvents;
  final int? eventsBytes;

  /// `succeeded` / `failed` / `aborted` / `filtered` / `succeeded_with_failures`
  /// — destination delivery status returned in `dataPlane.events.deliveryStatus`
  /// API responses.
  final String? deliveryStatus;

  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class RudderstackCallResult<T> {
  /// Creates a call result.
  const RudderstackCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final RudderstackResult? result;
}

/// Wraps a RudderStack API call in a CLIENT span. [operation] is one
/// of `track`, `identify`, `page`, `screen`, `group`, `alias`,
/// `batch`, `sources.list`, `sources.create`, `destinations.list`,
/// `destinations.create`, `transformations.create`,
/// `events.delivery_status`, `events.failed_records`,
/// `workspace.config`.
Future<T> tracedRudderstack<T>({
  required String operation,
  required Future<RudderstackCallResult<T>> Function() invoke,
}) async {
  if (rudderstackInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'rudderstack',
    'rpc.method': operation,
    'rudderstack.operation': operation,
  };

  final span = _tracer().startSpan(
    'rudderstack $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.workspaceId != null) {
        extras.add(OTelAPI.attributeString(
          'rudderstack.workspace.id',
          r.result!.workspaceId!,
        ));
      }
      if (r.result!.sourceId != null) {
        extras.add(OTelAPI.attributeString(
          'rudderstack.source.id',
          r.result!.sourceId!,
        ));
      }
      if (r.result!.sourceType != null) {
        extras.add(OTelAPI.attributeString(
          'rudderstack.source.type',
          r.result!.sourceType!,
        ));
      }
      if (r.result!.writeKey != null) {
        extras.add(OTelAPI.attributeString(
          'rudderstack.source.write_key',
          r.result!.writeKey!,
        ));
      }
      if (r.result!.destinationId != null) {
        extras.add(OTelAPI.attributeString(
          'rudderstack.destination.id',
          r.result!.destinationId!,
        ));
      }
      if (r.result!.destinationType != null) {
        extras.add(OTelAPI.attributeString(
          'rudderstack.destination.type',
          r.result!.destinationType!,
        ));
      }
      if (r.result!.eventType != null) {
        extras.add(OTelAPI.attributeString(
          'rudderstack.event.type',
          r.result!.eventType!,
        ));
      }
      if (r.result!.eventName != null) {
        extras.add(OTelAPI.attributeString(
          'rudderstack.event.name',
          r.result!.eventName!,
        ));
      }
      if (r.result!.deliveryMode != null) {
        extras.add(OTelAPI.attributeString(
          'rudderstack.delivery.mode',
          r.result!.deliveryMode!,
        ));
      }
      if (r.result!.transformationId != null) {
        extras.add(OTelAPI.attributeString(
          'rudderstack.transformation.id',
          r.result!.transformationId!,
        ));
      }
      if (r.result!.transformationStatus != null) {
        extras.add(OTelAPI.attributeString(
          'rudderstack.transformation.status',
          r.result!.transformationStatus!,
        ));
        if (r.result!.transformationStatus == 'error') {
          span.setStatus(
            SpanStatusCode.Error,
            'RudderStack transformation error',
          );
        }
      }
      if (r.result!.batchSize != null) {
        extras.add(OTelAPI.attributeInt(
          'rudderstack.batch.size',
          r.result!.batchSize!,
        ));
      }
      if (r.result!.eventsEvents != null) {
        extras.add(OTelAPI.attributeInt(
          'rudderstack.events.count',
          r.result!.eventsEvents!,
        ));
      }
      if (r.result!.eventsBytes != null) {
        extras.add(OTelAPI.attributeInt(
          'rudderstack.events.bytes',
          r.result!.eventsBytes!,
        ));
      }
      if (r.result!.deliveryStatus != null) {
        extras.add(OTelAPI.attributeString(
          'rudderstack.delivery.status',
          r.result!.deliveryStatus!,
        ));
        if (r.result!.deliveryStatus == 'failed' ||
            r.result!.deliveryStatus == 'aborted') {
          span.setStatus(
            SpanStatusCode.Error,
            'RudderStack delivery ${r.result!.deliveryStatus}',
          );
        }
      }
      if (r.result!.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'RudderStack HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
