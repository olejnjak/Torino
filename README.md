# Torino

Torino is a caching tool for XCFrameworks built by [Carthage][carthage]. Torino is considered an evolution to [Rome][rome] as its features are heavily inspired from its past usage, but focused strictly on XCFrameworks. Also big credit goes to [@LukasHromadnik](https://github.com/LukasHromadnik) as quite a lot of code was based on his private work.

**⚠️ Torino is in early development so you should not rely on it yet**

## Installation

The simplest usage is to use [Mint](https://github.com/yonaskolb/Mint), just add Torino to your Mintfile and you are ready to go.

```
olejnjak/Torino@main
```

## Usage

Torino currently supports several commands that all take `--prefix` parameter that is used for caching binaries with correct Swift version. This parameter is optional and if ommited, Torino will try to get appropriate prefix for you, based on selected swift version (`swift -version`).

### Upload cache

Upload command has single option `--prefix`. This way you can for example distinguish between compilers that created uploaded builds. 

```
Torino upload --prefix "Swift-5.5"
```

### Download cache

Download command has single option `--prefix`.

```
Torino download --prefix "Swift-5.5"
```

### Bootstrap

This command is designed to simplify bootstrapping your projects. At first it tries to get your dependencies from cache (local or remote based on your configuration), then it calls `carthage bootstrap` with respective arguments, to ensure you have all dependencies and then optionally caches new dependencies (`--upload`).

```
Torino bootstrap --prefix "Swift-5.5" --platform iOS --upload
```

### Update

This command is designed simplify updating dependencies on your projects. At first it runs `carthage update --no-build` to update your _Cartfile.resolved_, then tries to get dependencies from cache, the runs `carthage build` with respective arguments and optionally caches new dependencies (`--upload`).

```
Torino update --prefix "Swift-5.5" --platform iOS --upload
```

### Remote caching

Torino currently supports remote cache stored in GCP buckets. To support that you need to provide two environment variables:

`TORINO_GCP_BUCKET` - name of bucket that will be used for storage<br>
`TORINO_GCP_SERVICE_ACCOUNT_PATH` - location of service account that will be used for access to specified bucket

### Environment configuration

Here you can find additional environment variables that can configure Torino behavior

`TORINO_LOG_LEVEL` - set to `debug` if you want to increase verbosity of output

## Naming 

If you wonder why is Torino named after this Italian 🇮🇹  city, it is quite simple. As it works on top of [Carthage 🇹🇳][carthage] and is inspired by [Rome 🇮🇹][rome] and I am a fan of Juventus FC 🖤🤍 it was quite natural to name it this way 😎

[carthage]: https://github.com/Carthage/Carthage
[rome]: https://github.com/tmspzz/Rome
