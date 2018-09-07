module UUID.Version3.Variant1 exposing
    ( withNamespace
    , encode, decoder
    )

{-| Variant 1 version 3 UUIDs provide 122 bits of randomness, based on a hash of a namespace UUID and a name (using MD5).


## Generating

@docs withNamespace


## JSON

@docs encode, decoder

-}

import Internal.UUID as I
import Json.Decode
import Json.Encode
import MD5
import String.UTF8
import UUID exposing (UUID, Variant1, Version3)
import UUID.Version3 as V3


{-| Version 3 UUIDs are generated using an MD5 hash of an existing "namespace" UUID and a name.

    "hello"
        |> withNamespace UUID.nil
        |> UUID.canonical -- == "a6c0426f-f9a3-3b59-a62f-4807c382b768"

-}
withNamespace : UUID version variant -> String -> UUID Version3 Variant1
withNamespace uuid =
    I.withHashedNamespace MD5.hexInOctets uuid
        >> I.setVersion3
        >> I.setVariant1


{-| Encode a variant 1 version 3 UUID as a JSON string.

    Json.Encode.encode 0 (encode someUUID) -- e.g. "\"a6c0426f-f9a3-3b59-a62f-4807c382b768\""

-}
encode : UUID Version3 Variant1 -> Json.Encode.Value
encode =
    I.encode


{-| Decodes a UUID from a JSON string. Fails if UUID is not version 3 or variant 1.

    Json.Decode.decodeValue decoder someValue
        |> UUID.canonical -- e.g. "a6c0426f-f9a3-3b59-a62f-4807c382b768"

-}
decoder : Json.Decode.Decoder (UUID Version3 Variant1)
decoder =
    V3.decoder
        |> Json.Decode.andThen I.checkVariant1