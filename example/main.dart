// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_rudderstack/otel_rudderstack.dart';

/// Traces RudderStack calls with OpenTelemetry.
///
/// `otel_rudderstack` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each RudderStack call in
/// [tracedRudderstack]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'rudderstack-example');

  // Wraps a RudderStack API call in a CLIENT span.
  final rudderstackId = await tracedRudderstack<String>(
    operation: 'sources.create',
    invoke: () async {
      // Make the RudderStack call here, then report what it returned.
      const id = 'rudderstack_8f3a2c';
      return const RudderstackCallResult(
          value: id,
          result: RudderstackResult(
              workspaceId: 'workspace_8f3a2c',
              sourceId: 'source_8f3a2c',
              sourceType: 'javascript',
              writeKey: 'orders/2026/inv-1042.pdf',
              destinationId: 'destination_8f3a2c',
              destinationType: 'WEBHOOK',
              eventType: 'track',
              eventName: 'order.created',
              deliveryMode: 'cloud',
              transformationId: 'transformation_8f3a2c',
              transformationStatus: 'success',
              batchSize: 512,
              eventsEvents: 1,
              eventsBytes: 512,
              deliveryStatus: 'succeeded',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedRudderstack sources.create returned $rudderstackId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutRudderstackInstrumentationAsync.
  await runWithoutRudderstackInstrumentationAsync(
    () => tracedRudderstack<String>(
      operation: 'sources.create',
      invoke: () async {
        const id = 'rudderstack_8f3a2c';
        return const RudderstackCallResult(
            value: id,
            result: RudderstackResult(
                workspaceId: 'workspace_8f3a2c',
                sourceId: 'source_8f3a2c',
                sourceType: 'javascript',
                writeKey: 'orders/2026/inv-1042.pdf',
                destinationId: 'destination_8f3a2c',
                destinationType: 'WEBHOOK',
                eventType: 'track',
                eventName: 'order.created',
                deliveryMode: 'cloud',
                transformationId: 'transformation_8f3a2c',
                transformationStatus: 'success',
                batchSize: 512,
                eventsEvents: 1,
                eventsBytes: 512,
                deliveryStatus: 'succeeded',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
