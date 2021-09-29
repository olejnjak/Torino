# Torino

Torino is a caching tool for XCFrameworks built by [Carthage][carthage]. Torino is considered an evolution to [Rome][rome] as its features are heavily inspired from its past usage, but focused strictly on XCFrameworks. Also big credit goes to [@LukasHromadnik](https://github.com/LukasHromadnik) as quite a lot of code was based on his private work.

**⚠️ Torino is in early alpha so you should not rely on it yet**

## Installation

The simplest usage is to use [Mint](https://github.com/yonaskolb/Mint), just add Torino to your Mintfile and you are ready to go.

```
olejnjak/Torino@main
```

## Usage

Torino currently supports only `download` and `upload` commands that both take a single `--prefix` parameter that is used for caching binaries with correct Swift version.

## Features

Currently Torino supports only caching on single device which means that if you have shared dependencies (and its versions) on more projects, you don't have to compile it several times (or copy it several times), you can use Torino to do that.

It is planned that in near future remote cache storage will be supported. For now the first supported remote storage should be GCP buckets.

Other plans might be introducing `bootstrap` and `update` commands that could optimize calling respective [Carthage][carthage] commands to automatically reduce amount of compiled code, but this is still in phase of brainstorming pros and cons.

## Naming 

If you wonder why is Torino named after this Italian 🇮🇹  city, it is quite simple. As it works on top of [Carthage 🇹🇳][carthage] and is inspired by [Rome 🇮🇹][rome] and I am a fan of Juventus FC 🖤🤍 it was quite natural to name it this way 😎

[carthage]: https://github.com/Carthage/Carthage
[rome]: https://github.com/tmspzz/Rome