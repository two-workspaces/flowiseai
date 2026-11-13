# Deploy and Host FlowiseAI on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/flowiseai-server?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=flowiseai)

Flowise is an open-source visual builder for LLM apps: drag nodes together to make chatbots, AI agents and RAG pipelines over your documents, then call them through an API or embed them in a website. This template runs it on Railway as one service, with its SQLite database, credentials and uploads on a volume, and the admin account created from variables before the app goes online.

This is a community template, not made or supported by FlowiseAI.

## About Hosting FlowiseAI

A fresh Flowise opens a sign-up page that makes whoever loads it first the owner of the instance. This template closes that gap: on the first boot it starts Flowise on an internal port, creates the admin from `ADMIN_EMAIL` and `ADMIN_PASSWORD`, and only then starts it on the public domain. Sign-up is closed from then on.

It also:

- keeps the database, the encryption key for your stored API keys, logs and uploaded files on a volume
- sizes Node's memory to your plan, so Flowise collects garbage instead of being killed on small plans
- tells Flowise it's behind Railway's proxy, so https and client addresses are read right

**Log in:** open the service's domain and sign in with `ADMIN_EMAIL` and the `ADMIN_PASSWORD` from the Variables tab. Then add your model provider's key under **Credentials** and build a flow.

For heavy traffic, Flowise also runs in queue mode with workers, Postgres and Redis; that's a separate template.

## Common Use Cases

- Chatbots that answer from your documents (RAG), embedded on a website
- AI agents with tools: web search, APIs, code, databases
- Prototyping LLM workflows and exposing them as an API for your app

## Dependencies for FlowiseAI Hosting

- An API key for a model provider (OpenAI, Anthropic, Google, OpenRouter and others), or a model server such as Ollama

### Deployment Dependencies

- [Flowise docs](https://docs.flowiseai.com)
- [FlowiseAI/Flowise](https://github.com/FlowiseAI/Flowise)
- [Template source](https://github.com/two-workspaces/flowiseai)

### Implementation Details

- **Tested on Railway:** PENDING
- **Variables after the first boot:** `ADMIN_EMAIL` and `ADMIN_PASSWORD` are read once. Change your email or password inside Flowise afterwards; editing the variables does nothing.
- **Memory:** PENDING
- **Image:** `ghcr.io/two-workspaces/flowiseai`, built from this repository's Dockerfile on `flowiseai/flowise:3.1.4`.

## Why Deploy FlowiseAI on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying FlowiseAI on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
