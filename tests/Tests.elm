module Tests exposing (suite)

import Bytes.Encode
import Expect
import Fuzz exposing (Fuzzer)
import Regex exposing (Regex)
import Shrink exposing (noShrink)
import Test exposing (Test, describe, fuzz)
import UUID
    exposing
        ( Error(..)
        , Representation(..)
        , UUID
        , forBytes
        , forBytesV3
        , forName
        , forNameV3
        , fromBytes
        , fromString
        , generator
        , toBytes
        , toRepresentation
        , toString
        )


suite : Test
suite =
    describe "UUID"
        [ describe "formatting"
            [ fuzz fuzzer "Canonical" <|
                \uuid ->
                    Expect.true (toRepresentation Canonical uuid ++ " is not in the canonical textual representation") <|
                        isCanonicalFormat (toRepresentation Canonical uuid)
            , fuzz fuzzer "GUID" <|
                \uuid ->
                    Expect.true (toRepresentation Guid uuid ++ " is not in Microsoft’s textual representation of GUIDs") <|
                        isGuidFormat (toRepresentation Guid uuid)
            , fuzz fuzzer "URN" <|
                \uuid ->
                    Expect.true (toRepresentation Urn uuid ++ " is not a correctly-formatted URN for the UUID") <|
                        isUrnFormat (toRepresentation Urn uuid)
            , fuzz fuzzer "toString is canonical" <|
                \uuid -> Expect.equal (toRepresentation Canonical uuid) (toString uuid)
            , fuzz fuzzer "Can read any representation" <|
                \uuid ->
                    Expect.all
                        [ Expect.equal (fromString (toRepresentation Canonical uuid))
                        , Expect.equal (fromString (toRepresentation Guid uuid))
                        , Expect.equal (fromString (toRepresentation Urn uuid))
                        ]
                        (Ok uuid)
            ]
        , describe "Bytes" <|
            [ fuzz fuzzer "can convert to and from bytes without a problem" <|
                \uuid -> Expect.equal (Ok uuid) (fromBytes (toBytes uuid))
            ]
        ]



-- FUZZER


fuzzer : Fuzzer UUID
fuzzer =
    Fuzz.oneOf [ fuzzerV3, fuzzerV4, fuzzerV5 ]


fuzzerV3 : Fuzzer UUID
fuzzerV3 =
    Fuzz.oneOf
        [ Fuzz.map2 forNameV3 Fuzz.string fuzzerV4
        , Fuzz.map2 forBytesV3 (Fuzz.map (Bytes.Encode.encode << Bytes.Encode.string) Fuzz.string) fuzzerV4
        ]


fuzzerV4 : Fuzzer UUID
fuzzerV4 =
    Fuzz.custom generator noShrink


fuzzerV5 : Fuzzer UUID
fuzzerV5 =
    Fuzz.oneOf
        [ Fuzz.map2 forName Fuzz.string fuzzerV4
        , Fuzz.map2 forBytes (Fuzz.map (Bytes.Encode.encode << Bytes.Encode.string) Fuzz.string) fuzzerV4
        ]



-- REGEX HELPERS


isCanonicalFormat : String -> Bool
isCanonicalFormat =
    Regex.contains canonicalRegex


isUrnFormat : String -> Bool
isUrnFormat =
    Regex.contains urnRegex


isGuidFormat : String -> Bool
isGuidFormat =
    Regex.contains guidRegex


canonicalRegex : Regex
canonicalRegex =
    Regex.fromString ("^" ++ uuidRegexString ++ "$")
        |> Maybe.withDefault Regex.never


urnRegex : Regex
urnRegex =
    Regex.fromString ("^urn:uuid:" ++ uuidRegexString ++ "$")
        |> Maybe.withDefault Regex.never


guidRegex : Regex
guidRegex =
    Regex.fromString ("^\\{" ++ uuidRegexString ++ "\\}$")
        |> Maybe.withDefault Regex.never


uuidRegexString : String
uuidRegexString =
    "[0-f]{8}-[0-f]{4}-[1-5][0-f]{3}-[8-d][0-f]{3}-[0-f]{12}"
