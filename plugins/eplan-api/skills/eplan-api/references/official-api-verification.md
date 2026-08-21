# Verify uncovered APIs against EPLAN 2026

Use the official EPLAN Platform API 2026 documentation as the authoritative source for an EPLAN
type or member not demonstrated by the inspected Utilities:

https://www.eplan.help/en-us/Infoportal/Content/api/2026/index.html

The documentation landing page identifies the published help as EPLAN API version 2026.0.3. Keep
the requested/installed EPLAN build separate from this documentation version and disclose any
mismatch.

## Verification procedure

1. Identify the proposed fully qualified namespace, type, and member from the task.
2. Search within the official 2026 API help; do not rely on a general web-search snippet.
3. Open the direct type/member page and confirm:
   - declaring namespace and assembly;
   - member name and complete signature;
   - parameter and return semantics;
   - lifecycle, initialization, thread, licensing, and object-validity notes;
   - exceptions, remarks, examples, and version/deprecation notes.
4. Compare the official signature with installed 2026 XML documentation or assembly metadata when
   available. Investigate discrepancies instead of selecting whichever form compiles first.
5. Add only the minimum raw API required. Prefer placing it in the relevant Utility so future call
   sites reuse one verified abstraction.
6. Build against the selected installation and record the direct official URL beside the change
   summary or verification notes.

## Stop conditions

Do not present raw API code as verified when:

- only another EPLAN version documents the member;
- the direct official page cannot be opened;
- the installed signature conflicts with the 2026 page;
- a property identifier, enum value, object lifecycle, or transaction requirement remains unclear.

In these cases, provide pseudocode or a marked integration point and state exactly what evidence is
missing.

## Verified property notes

- `11011` is `PagePropertyList.PAGE_NOMINATIOMN`, documented as the page description:
  https://www.eplan.help/en-us/infoportal/content/api/2026/Eplan.EplApi.DataModelu~Eplan.EplApi.DataModel.PagePropertyList~PAGE_NOMINATIOMN.html
- `20008` is `Properties.FunctionBase.FUNC_IDENTDEVICETAGWITHOUTSTRUCTURES`, documented as the
  identifying device tag without project structures—not the official visible-name property:
  https://www.eplan.help/en-us/infoportal/content/api/2026/Eplan.EplApi.DataModelu~Eplan.EplApi.DataModel.Properties%2BFunctionBase.html
