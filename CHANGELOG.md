# 0.2.7-rust-1.44.0

* Upgrade to Rust [`1.44.0`](https://blog.rust-lang.org/2020/06/04/Rust-1.44.0.html)

# 0.2.7-rust-1.43.1

* Upgrade to Rust [`1.43.1`](https://blog.rust-lang.org/2020/05/07/Rust.1.43.1.html)
# 0.2.7-rust-1.43.0

* Upgrade to Rust [`1.43.0`](https://blog.rust-lang.org/2020/04/23/Rust-1.43.0.html)

# 0.2.7-rust-1.42.0

* Invoke user provided hooks for customized installation, building, and packaging needs [#59](https://github.com/softprops/lambda-rust/pull/59)

# 0.2.6-rust-1.42.0

* Upgrade to Rust [`1.42.0`](https://blog.rust-lang.org/2020/03/12/Rust-1.42.html)

# 0.2.6-rust-1.41.0

* Upgrade to Rust [`1.41.0`](https://blog.rust-lang.org/2020/01/30/Rust-1.41.0.html)

# 0.2.6-rust-1.40.0

* Upgrade to Rust [`1.40.0`](https://blog.rust-lang.org/2019/12/19/Rust-1.40.0.html)

# 0.2.6-rust-1.39.0

* Upgrade to Rust [`1.39.0`](https://blog.rust-lang.org/2019/11/07/Rust-1.39.0.html)

# 0.2.6-rust-1.38.0

* Debug info in `release` profiles is now only included when a `DEBUGINFO` env variable is provided. This perserves previous behavior and makes enabling this an opt-in feature for `release` binaries

# 0.2.5-rust-1.38.0

* reduced total size of docker image by **~277MB** leveraging new [rustup `minimal` profile](https://blog.rust-lang.org/2019/10/15/Rustup-1.20.0.html)

# 0.2.4-rust-1.38.0

* Fixed regression from previous release cargo workspaces we failing to resolve binary names
* `dev` profile builds are no longer run though `strip` which increases their binary size but retain their debug information
* `release` profile builds (the default) still have debug information stripped but produce a file named `{your-binary-name}.debug` which final release binary contains a debug link to.

# 0.2.3-rust-1.38.0

* Upgrade to Rust [`1.38.0`](https://blog.rust-lang.org/2019/09/26/Rust-1.38.0.html)
* You can generate debug artifacts with adding `-e PROFILE=dev` to your docker runs

# 0.2.2-rust-1.37.0

* Improve logic for selecting binaries to include in deployment zip, especially on Windows

# 0.2.1-rust-1.37.0

* Upgrade to Rust [`1.37.0`](https://blog.rust-lang.org/2019/08/15/Rust-1.37.0.html)

# 0.2.1-rust-1.36.0

* Upgrade to Rust [`1.36.0`](https://blog.rust-lang.org/2019/07/04/Rust-1.36.0.html)

# 0.2.1-rust-1.35.0

* Upgrade to Rust [`1.35.0`](https://blog.rust-lang.org/2019/05/23/Rust-1.35.0.html)

# 0.2.1-rust-1.34.2

* Upgrade to Rust [`1.34.2`](https://blog.rust-lang.org/2019/05/14/Rust-1.34.2.html)

# 0.2.1-rust-1.34.1

* Upgrade to Rust [`1.34.1`](https://blog.rust-lang.org/2019/04/25/Rust-1.34.1.html)

# 0.2.1-rust-1.34.0

* Upgrade to Rust [`1.34.0`](https://blog.rust-lang.org/2019/04/11/Rust-1.34.0.html)

# 0.2.1-rust-1.33.0

* Upgrade to Rust [`1.33.0`](https://blog.rust-lang.org/2019/02/28/Rust-1.33.0.html)

# 0.2.1-rust-1.32.0

* Added support for `BIN` env variable for naming precisely the bin to package
* Handle case where Cargo bin is explicitly named `bootstrap`
* Introduce integration testing

#  0.2.0-rust-1.32.0

* Upgrade to Rust [`1.32.0`](https://blog.rust-lang.org/2019/01/17/Rust-1.32.0.html)

# 0.2.0-rust-1.31.1

* Upgrade to Rust [`1.31.1`](https://blog.rust-lang.org/2018/12/20/Rust-1.31.1.html)

# 0.2.0-rust-1.31.0

* Breaking change: move to now officially supported `provided` runtime
* Upgrade to Rust `1.31.0`, enabling the first stable version `2018 edition` Rust.

# 0.1.*

* Rust versions for `python 3.6` runtime targetting [rust crowbar](https://github.com/ilianaw/rust-crowbar) and [lando](https://github.com/softprops/lando) applications