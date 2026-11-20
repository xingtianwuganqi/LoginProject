# ShipDock CLI 发布素材格式与命令

ShipDock CLI 在 macOS 上校验 iOS App Store 发布素材，并生成本地上传清单。构建需要 macOS 13 或更新版本及 Swift 6 工具链。

## 发布素材目录

将 `release/` 替换为项目实际的发布素材目录。默认范围 `all` 会同时校验元数据和截图。

```text
release/
├── shipdock.json
├── metadata/
│   ├── copyright.txt
│   ├── en-US/
│   │   ├── name.txt
│   │   ├── description.txt
│   │   ├── keywords.txt
│   │   ├── support_url.txt
│   │   └── privacy_url.txt
│   └── zh-Hans/
│       └── description.txt
└── screenshots/
    ├── en-US/
    │   ├── 2_home.png
    │   └── 10_detail.png
    └── zh-Hans/
        └── 1_home.jpg
```

`shipdock.json` 示例

```json
{
  "schemaVersion": 1,
  "displayName": "Example",
  "bundleIdentifier": "com.example.app",
  "platform": "ios",
  "appVersion": "1.2.0",
  "primaryLocale": "en-US"
}
```

- `schemaVersion` 固定为 `1`，`platform` 固定为 `ios`。`bundleIdentifier` 和 `appVersion` 必填，`displayName` 和 `primaryLocale` 可省略。配置只存放非敏感信息。
- 元数据使用 UTF-8。每个语言目录支持 `name.txt`、`subtitle.txt`、`description.txt`、`keywords.txt`、`promotional_text.txt`、`release_notes.txt`、`support_url.txt`、`privacy_url.txt` 和 `marketing_url.txt`。可在 `metadata/` 下放置共用的 `copyright.txt`。
- 截图支持 `.png`、`.jpg`、`.jpeg`。图片必须符合支持的 iPhone 或 iPad 尺寸，且无 Alpha 通道。按文件名自然排序，例如 `2_home.png` 排在 `10_detail.png` 前。
- 语言目录使用 ShipDock 识别的 App Store 语言代码，例如 `en-US`、`zh-Hans`、`ja`。`metadata/default/` 会被跳过。素材请使用普通文件和目录。

## CLI 命令

从任意项目目录运行 ShipDock 仓库中的 CLI。以下示例通过 `--package-path` 指定 CLI 所在仓库，并用绝对路径定位当前项目的发布素材。

```bash
swift run --package-path "$HOME/Desktop/Github/shipdock" shipdock --help
swift run --package-path "$HOME/Desktop/Github/shipdock" shipdock doctor --format json
swift run --package-path "$HOME/Desktop/Github/shipdock" shipdock validate "$PWD/release" --scope all
swift run --package-path "$HOME/Desktop/Github/shipdock" shipdock plan "$PWD/release" --scope metadata --format json
```

如果 `shipdock` 已加入 `PATH`，可以直接运行以下命令。

```text
shipdock doctor [--format text|json]
shipdock validate <release-dir> [--scope metadata|screenshots|all] [--format text|json]
shipdock plan <release-dir> [--scope metadata|screenshots|all] [--format text|json]
```

- `doctor` 探测本机 Fastlane 可执行文件。`validate` 校验配置及素材。`plan` 在校验通过后生成本地清单，包含发布目标、范围、文件 SHA-256 和计划 ID。
- 默认输出为 `text`。`--format json` 在 stdout 输出单个带 `schemaVersion` 的 JSON 对象。
- 退出码 `0` 表示成功，`2` 表示参数或本地校验失败，`3` 表示所需能力不可用。

## App Store Connect 凭证检查

在任意目录运行此命令，校验凭证 JSON 和它引用的 `.p8` 私钥。

```bash
/Users/jingjun/Desktop/Github/shipdock/.build/release/shipdock doctor \
  --credentials "/Users/jingjun/Documents/AppStoreConnectApikey/app_store_connect.json" \
  --format json
```

`credentialsValid: true` 表示凭证通过本地校验。

## 同步到 App Store Connect

在项目目录的交互式终端运行 `sync`。把 `$PWD/release` 换成实际的发布素材目录。支持 `metadata`、`screenshots` 和 `all`，默认 `all`。需要本机 Fastlane 2.237.0、仓库外的团队凭证 JSON，以及 App Store Connect 中与 `shipdock.json` 一致、处于 Prepare for Submission 的 iOS 版本。

### 本机 Fastlane 安装状态

本机已安装 Fastlane 2.237.0，可在终端直接运行 `fastlane`。通过独立安装提供的命令入口是 `/opt/homebrew/bin/fastlane`。运行 `command -v fastlane` 可查看当前终端选中的入口。

```bash
command -v fastlane
fastlane --version
fastlane deliver --help
/Users/jingjun/Desktop/Github/shipdock/.build/release/shipdock doctor --format json
```

以上本机检查均已通过。真实 App Store Connect 上传尚未验收。

仅同步文案

```bash
/Users/jingjun/Desktop/Github/shipdock/.build/release/shipdock sync "$PWD/release" \
  --credentials "/Users/jingjun/Documents/AppStoreConnectApikey/app_store_connect.json" \
  --scope metadata --format json
```

仅同步截图

```bash
/Users/jingjun/Desktop/Github/shipdock/.build/release/shipdock sync "$PWD/release" \
  --credentials "/Users/jingjun/Documents/AppStoreConnectApikey/app_store_connect.json" \
  --scope screenshots --format json
```

先核对终端显示的目标、范围、文件和计划 ID，输入 `sync` 确认。Fastlane 生成预览并等待上传时，输入 `upload` 继续。也可加 `--plan-id <id>` 要求当前素材与先前生成的计划一致。使用 JSON 输出时，确认提示和过程状态出现在 stderr，最终结果写到 stdout。

元数据同步要求目标没有审核附件。截图同步要求线上已有截图处理完成，Fastlane 可能调整截图排序。`all` 的上传可能部分完成。退出码 `4` 表示凭证、权限或缺少交互终端，`5` 表示远端预检或 Fastlane 失败，`6` 表示结果未知，`130` 表示上传前取消。出现失败或未知状态时，先核对 App Store Connect 再决定是否重试。
