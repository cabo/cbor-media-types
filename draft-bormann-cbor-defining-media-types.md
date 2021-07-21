---
coding: utf-8

title: Defining media types with CBOR and CDDL
abbrev: CBOR media types
docname: draft-bormann-cbor-defining-media-types-latest
date: 2021-07-21
category: info

ipr: trust200902
area: Applications
workgroup: CBOR Working Group
keyword: Internet-Draft

stand_alone: yes
pi: [toc, sortrefs, symrefs, comments]
kramdown_options:
  auto_id_prefix: sec-

author:
  -
    ins: C. Bormann
    name: Carsten Bormann
    org: Universität Bremen TZI
    orgascii: Universitaet Bremen TZI
    street: Postfach 330440
    city: Bremen
    code: D-28359
    country: Germany
    phone: +49-421-218-63921
    email: cabo@tzi.org

normative:
  RFC8949: cbor
  RFC8742: seq
  RFC8610: cddl
  RFC7252: coap
  RFC7230: http-msr
  RFC6838: media-types-reg
  RFC5234: abnf
  RFC8259: json
  IANA.media-types: media-types
  IANA.core-parameters: core-parameters
  IANA.cose: iana-cose
  RFC8152: cose
  I-D.ietf-cose-rfc8152bis-struct: cose-s
  I-D.ietf-cose-rfc8152bis-algs: cose-a
  I-D.ietf-cose-hash-algs: cose-h
  BCP201: agility
  I-D.ietf-jsonpath-base: jsonpath

informative:
  RFC8428: senml
  RFC8710: multipart-core
  I-D.ietf-cbor-packed: packed
  RFC1951: deflate
  RFC7932: brotli

entity:
        SELF: "[RFC-XXXX]"

--- abstract

This short draft explains how to create Internet media types (content
types, content formats) using CBOR, with a focus on selecting certain
alternatives and providing the right information to the relevant IANA
registration processes.

--- middle

# Introduction

CBOR {{-cbor}} is a representation format that can be used as a basis
for defining
data formats for interchange.
Internet Media Types {{-media-types-reg}} allow to give names to such
formats and register them with IANA, these names are then directly
useful in protocols such as HTTP and E-Mail.
Content-Formats ({{Sections 5.10.3, 5.10.4, and 12.3 of -coap}}) provide a
way to assign small numbers to combinations of media-types, their
parameters, and content-codings {{Section 8.5 of -http-msr}},
employing the Content-Formats
{{subregistry<IANA.core-parameters}}{: relative="#content-formats"}
of the CoRE Parameters registry {{-core-parameters}}.

## Terminology

{::boilerplate bcp14info-tagged}

# Using CBOR

In many cases, the interchange format and thus media type to be
defined will be a single CBOR data item: See {{sec-item}} for details.
In some cases, a CBOR sequence {{-seq}} will be employed instead, which
calls for a slightly different kind of registration: See {{sec-seq}} for details.

## The +cbor structured syntax suffix for CBOR data items {#sec-item}

{{Section 9.5 of -cbor}} registers a "structured syntax suffix" of
`+cbor` for media types based on a single encoded CBOR data item.

The idea of a structured syntax suffix is that processors that do not
know the specific semantics of a cbor-based media type can still
process its syntactical structure once they recognize that the media
type name ends in `+cbor`.  While the usefulness of that often does
not extend beyond diagnostics and debugging, this is still a valid
motivation.  Also, some generic processing schemes such as {{-packed}}
may be directly applicable to all `+cbor`-suffixed media types.

For example, SenML, in {{Section 6 of -senml}}, defines a
media type `application/senml+cbor`, among its related media types
such as `application/senml+json`.

## The +cbor-seq structured syntax suffix for CBOR sequences {#sec-seq}

{{Section 3 of -seq}} says:

<blockquote markdown="1">
[...] the "+cbor-seq" structured syntax suffix [...] SHOULD be used by a
media type when the result of parsing the bytes of the media type
object as a CBOR Sequence is meaningful and is at least sometimes not
just a single CBOR data item.  (Without the qualification at the end,
this sentence this sentence is trivially true for any +cbor media
type, which of course should continue to use the "+cbor" structured
syntax suffix.)
</blockquote>

`application/missing-blocks+cbor-seq`, as registered in {{Section 12.2
of ?I-D.ietf-core-new-block}}, is an example.

## Getting the media type registration

The media type registration template defined in {{-media-types-reg}} is
full of historic arcana that is not often fully explained in that RFC.
{{sec-example}} defines a hypothetical media type application/foo+cbor.

A few aspects warrant further discussion:

* The *Encoding considerations* are often used in a way that is
  different from the intention in {{Section 4.8 of -media-types-reg}},
  which is a simple selection between "binary" and various
  alternatives that are now all obsolete.

* At the time of writing this, the *Fragment identifier
  considerations* are mostly irrelevant for CBOR; just in case we do
  come up with a fragment identifier syntax (based on {{-jsonpath}}?),
  the boilerplate given in {{sec-example}} can be used.

* The *Intended Usage* is always COMMON, except for OBSOLETE or
  LIMITED USE specifications.  The latter case can probably best be
  elaborated as "call us before you use this".  A *Restrictions on
  usage* field is provided to possibly reduce the number of phone
  calls in this case; otherwise that field is "N/A".

* {{-media-types-reg}} has fields *Author* and *Change Controller*.
  For IETF documents, the latter is always the IETF, as represented by
  the IESG (but see {{sec-example}}).

## Getting a Content-Format number registration

As per {{Section 12.3 of -coap}}, a content format number registration
requires an existing media-type registration, which you therefore need
to do first (or at least in parallel).  A Content-Format registration
needs two additional pieces of information:

* Is there a content-coding (erroneously called "Encoding" in {{Section
  12.3 of -coap}}) to be applied?  This is usually the identity
  content-coding (usually registered as `–`), or it can be a
  compression scheme such as `deflate` {{-deflate}}, `br` (brotli,
  {{-brotli}}), etc.
  For CBOR data items, traditional data compression does not often
  make a lot of sense (but it might, for large data items).
  An example for a content-format in the Content-Formats
  {{subregistry<IANA.core-parameters}}{: relative="#content-formats"} of
  the CoRE Parameters registry {{-core-parameters}} that does have a
  non-identity content-coding is 11060, which is `application/cbor`
  with `deflate` content-coding.

* Which number range should the registration go into?
  {{Section 12.3 of -coap}} provides four ranges

# Using COSE

COSE (RFC in {{-cose}}, soon to be supplanted by {{-cose-s}}, {{-cose-a}},
with {{-cose-h}}) provides cryptographic building blocks that can be used
in CBOR formats.  It is generally RECOMMENDED to use these instead of
home-brew crypto constructions whenever they are applicable.  Support
for libraries is one reason, but also the availability of crypto
agility {{-agility}} through the use of the COSE registries {{IANA.cose}}.

...

Note that COSE defines media types and content formats already.
These are generic formats that do not say anything further about the
syntax and the semantics of the CBOR data that may be contained in the
COSE constructs.

# Using CDDL

Many text-based protocols used in the IETF use ABNF {{-abnf}} to provide
formal, machine-readable definitions for their syntax.
The Concise Data Definition Language (CDDL, {{-cddl}}) fulfills the
analogous function for CBOR (as well as for JSON {{-json}}).
A specification that defines a CBOR (or JSON) based media type SHOULD
provide a CDDL specification, which is often *very* short (compare 
Figure
{{1<RFC8710}}{: relative="#figure-1"}
of {{RFC8710}}, as reproduced below).

~~~ cddl
multipart-core = [* multipart-part]
multipart-part = (type: uint .size 2, part: bytes / null)
~~~
{: title="Example CDDL specification as per Figure 1 of RFC 8710"}

See {{Appendix F of -cddl}} for a tool that can be used in validating,
as well as checking for the correct meaning, a CDDL snippet like the above.

...

--- back

# Example `application/foo+cbor` registration {#sec-example}

This appendix contains an example registration template for a
hypothetical `application/foo+cbor` media type (fashioned after that
in {{RFC8710}}), in a form that can be
pasted into a kramdown-rfc source file.

Note that the contact information and the change controller
information is not very well defined; this may get some comments
during media type registration review and IETF last call.
It may seem obvious to include the WG name in the contact information,
but that is likely to shut down before the specification becomes
irrelevant.
Recent RFCs are confused whether the change controller should be
simply "IETF" or simply "IESG", or "IESG" plus the iesg mail address
<iesg@ietf.org>.
{{?RFC9000}} is an interesting counter-example, as it seems to assume a
perpetual WG:

<blockquote markdown="1">
All registrations in this document are assigned a permanent status and list a
change controller of the IETF and a contact of the QUIC Working Group
(quic@ietf.org).
</blockquote>

{{-cbor}} probably has the most useful solution for the contact
information, assuming that the area ART (or at least its mail address)
will be around for a while:

<blockquote markdown="1">
Contact:
: IETF CBOR Working Group (cbor@ietf.org) or IETF Applications and Real-Time Area (art@ietf.org)
</blockquote>

##  Registration of Media Type application/foo+cbor

IANA is requested to register the following media type {{RFC6838}}:

Type name:
: application

Subtype name:
: foo+cbor

Required parameters:
: N/A

Optional parameters:
: N/A

Encoding considerations:
: binary

Security considerations:
: See the Security Considerations section of RFCXXXX.

Interoperability considerations:
: N/A

Published specification:
: RFCXXXX

Applications that use this media type:
: (__short description__)

Fragment identifier considerations:
: The syntax and semantics of
   fragment identifiers specified for application/multipart-core are
   as specified for application/cbor.  (At publication of this
   document, there is no fragment identification syntax defined for
   application/cbor.)

Additional information:
: Deprecated alias names for this type:
  : N/A

  Magic number(s):
  : N/A

  File extension(s):
  : N/A

  Macintosh file type code(s):
  : N/A

Person & email address to contact for further information:
   iesg@ietf.org

Intended usage:
: COMMON

Restrictions on usage:
: N/A

Author:
: FOO WG

Change controller:
: IESG

Provisional registration? (standards tree only):
: no



# Acknowledgements
{: numbered="false"}

...
