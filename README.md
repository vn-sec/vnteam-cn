# V&N Website

This is a repository for V&N website development.

For website repository, please visit [vn-website](https://github.com/vn-sec/vn-website).

## Getting Started

> [!CAUTION]
> Package manager is `pnpm` is required.

Use the following command to setup:

```shell
pnpm run setup
```

Modify configurations. And then start the development server:

```shell
pnpm run dev
```

If everything goes ok, you can commit your changes.

Run the following command to restore the website submodule:

> [!IMPORTANT]
> Brfore committing, you need to run this command to restore the website submodule.
> ```shell
> pnpm run clean
> ```

## Commands

The following commands are available:

- `submodule` - Get the submodule.
- `submodule:update` - Update the submodule to the latest commit.
- `setup` - If you want to do something (start the server, build, etc.) with the website, you need to run this command. \
  This will get the submodule and install the dependencies. It will run `apply` command automatically.
- `apply` - Apply your modifications to the website.
- `clean` - Clean your modifications to the website.

> The following commands require running `setup` command first:

- `start` - Apply and start the development server.
- `build` - Apply and build the website.
- `dev` - Start the development server.
- `check` - Check the website.
- `preview` - Preview the website.

For build, default output directory is in website submodule. You can change it by following command:

```shell
pnpm run build --outDir <output-directory>
```

If you change the website submodule directory, please modify [.env](./.env) file accordingly.

## License

Copyright (c) V&N Team. All rights reserved.

Licensed under the [MIT](./LICENSE) license.
