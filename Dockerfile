# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM node:18 AS client

COPY ./client /
WORKDIR /client

RUN npm install
RUN npm run release

FROM golang:1.21 AS server

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download
COPY . ./

RUN CGO_ENABLED=0 go build -mod=readonly -o /server ./cmd/server

# Now create separate deployment image
FROM gcr.io/distroless/base

# Copy template & assets
WORKDIR /app
COPY --from=server /server /app/server
COPY --from=client /.build/release /app/static

ENTRYPOINT ["./server"]
