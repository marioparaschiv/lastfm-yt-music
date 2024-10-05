---

<div align="center">
  <h3>🎶 Last.fm for YouTube Music </h3>
  <p>Last.fm integration for the YouTube Music iOS app.</p>
</div>

---

## Requirements

- Jailbroken iOS device, or one with sideloading capabilities
- Last.fm API key
- [Theos](https://theos.dev)

## Building

1. Navigate to <https://last.fm/api/account/create>
2. Fill in the following:
    - Contact email: Your email
    - Application name: (Anything)
    - Callback URL: `http://localhost:3000`
3. Fill in `MakeFile`:
    - `LASTFM_API_KEY`: API key from the previous step
    - `LASTFM_API_SECRET`: API secret from the previous step
4. Build with `make clean package FINALPACKAGE=1`
    > If you get `Makefile:8: /makefiles/common.mk: No such file or directory`, you do not have Theos installed. [Install Theos](https://theos.dev/docs/installation)

The resulting `.deb` tweak file will be in `packages/`.

## Licensing

See [LICENSE](/LICENSE).
