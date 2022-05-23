FROM swift:focal as builder
RUN chmod -R o+r /usr/lib/swift/CoreFoundation && \
    apt-get update && \
    apt-get install -y libssl-dev
COPY . .
RUN swift build -c release

FROM swift:focal-slim
ENV LOCAL_STORAGE_PATH=${LOCAL_STORAGE_PATH}
ENV SLACK_API_KEY=${SLACK_API_KEY}
ENV GITHUB_API_KEY=${GITHUB_API_KEY}
COPY --from=builder .build/release/Yotto .
CMD ["./Yotto"]
