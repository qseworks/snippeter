/// Current wall-clock time as epoch milliseconds (UTC).
///
/// All syncable rows store timestamps this way so the same integer compares
/// correctly across devices and maps to Postgres `timestamptz` on sync.
int nowMs() => DateTime.now().toUtc().millisecondsSinceEpoch;
