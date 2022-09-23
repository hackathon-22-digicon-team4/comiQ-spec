.PHONY: openapiv2
openapiv2:
	protoc -I ./api -I ./api/include --openapiv2_out=api ./api/api.proto
protolint:
	protolint lint -fix ./api/api.proto ./api/model.proto