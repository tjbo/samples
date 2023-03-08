use std::str::FromStr;
use aws_sdk_polly::model::{Engine, OutputFormat, VoiceId as AwsVoiceId};
use aws_sdk_polly::Client;
use aws_types::Credentials;
use http::Response;
use lambda_http::{
    http::StatusCode, service_fn, Error as LambdaError, IntoResponse, Request, RequestExt,
};
use serde::Deserialize;
use serde_json::json;
use timer_labs::types::VoiceId;

#[tokio::main]
async fn main() -> Result<(), LambdaError> {
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        .without_time()
        .init();

    let func = service_fn(my_handler);
    lambda_http::run(func).await?;
    Ok(())
}

#[derive(Deserialize, Debug)]
#[serde(rename_all(deserialize = "camelCase"))]
struct Payload {
    text: String,
    voice_id: VoiceId,
}

pub(crate) async fn my_handler(event: Request) -> Result<impl IntoResponse, LambdaError> {
    let body = event.payload::<Payload>()?;

    match body {
        Some(b) => {
            let text = b.text;
            let convert_text = String::from(&text);

            let polly_access_key = match std::env::var_os("POLLY_ACCESS_KEY") {
                Some(v) => v.into_string().unwrap(),
                None => panic!("$POLLY_ACCESS_KEY is not set"),
            };

            let polly_access_secret = match std::env::var_os("POLLY_ACCESS_SECRET") {
                Some(v) => v.into_string().unwrap(),
                None => panic!("$POLLY_ACCESS_SECRET is not set"),
            };

            let creds = Credentials::from(Credentials::new(
                polly_access_key,
                polly_access_secret,
                None,
                None,
                "polly_credentails_provider",
            ));

            let config = aws_config::from_env()
                .credentials_provider(creds)
                .load()
                .await;

            let client = Client::new(&config);

            match AwsVoiceId::from_str(&b.voice_id.to_string()) {
                Ok(v) => {
                    let response = client
                        .synthesize_speech()
                        .engine(Engine::Neural)
                        .output_format(OutputFormat::Mp3)
                        .text(convert_text)
                        .voice_id(v)
                        .send()
                        .await?;

                    let blob = response
                        .audio_stream
                        .collect()
                        .await
                        .expect("failed to read data");

                    let b = base64::encode(blob.into_bytes());

                    let response = Response::builder()
                        .status(StatusCode::OK)
                        .header("Content-Type", "application/json")
                        .body(
                            json!({
                              "payload": b,
                            })
                            .to_string(),
                        )
                        .map_err(Box::new)?;
                    Ok(response)
                }
                Err(_) => Err("Error: Not a vaild voiceId.".into()),
            }
        }
        None => Err("Error: No body provided.".into()),
    }
}
