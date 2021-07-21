TARGETS_DRAFTS := draft-bormann-cbor-defining-media-types 
TARGETS_TAGS := 
draft-bormann-cbor-defining-media-types-00.md: draft-bormann-cbor-defining-media-types.md
	sed -e 's/draft-bormann-cbor-defining-media-types-latest/draft-bormann-cbor-defining-media-types-00/g' $< >$@
