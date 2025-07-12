# ✅ Parser Compatibility Audit Checklist

For each new log format added to the LogFormatLibrary, complete the following checks to ensure system-wide compatibility.

---

## 🔍 Format Profile Integrity
- [ ] Has unique `id` and `name`
- [ ] `match.contains` is realistic and specific
- [ ] `match.format` is one of: `json`, `regex`, `delimited`, or `fallback`
- [ ] Optional: regex/delimiter present if required

---

## 📂 Field Mapping Validity
- [ ] Required fields mapped:
  - [ ] `timestamp`
  - [ ] `level`
  - [ ] `message`
- [ ] Optional fields clearly labeled (e.g., `conversation_id`, `context`, `media_type`)
- [ ] Indexes used for delimited formats are correct
- [ ] Regex capture group names match field definitions

---

## 🧪 Schema Compatibility
- [ ] Output matches expected schema for formatter (e.g., JSON array with consistent keys)
- [ ] Optional fields do not cause parser failure when missing
- [ ] Timestamps normalize cleanly to ISO-8601
- [ ] Redaction layer works across all fields

---

## 🤖 AI Consumption Readiness
- [ ] Cleaned log output supports chunking (e.g., groups of 10–50)
- [ ] Each log entry stands alone and has minimal noise
- [ ] Conversation or correlation IDs preserved if applicable

---

## 🔁 Cross-Module Interoperability
- [ ] Output is usable by:
  - [ ] AI Analyzer
  - [ ] Flow Logic (if conversation-aware)
  - [ ] Dashboard/Insights Layer
- [ ] File naming conventions followed (e.g., `Cleaned-Logs.json`)
- [ ] Parser skips/malformed lines are logged or counted

---

## 🧯 Failure Handling
- [ ] Script logs non-fatal errors with context (e.g., line number, reason)
- [ ] Missing fields fallback gracefully to `"unknown"` or `null`
- [ ] Regex mismatches handled without breaking processing loop

---

✅ Complete this checklist before deploying any new log parser into the production formatter.