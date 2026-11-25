# v0.2.0 Windows CI 验证准备

**待真实 Runner 验证。** 本轮只在本地准备。工作流配置 Windows/Linux 矩阵，Windows 加载 MSVC 开发环境后依次执行 Native build 和 Native test，两者失败都会使作业失败。工作流打印 checkout SHA、MoonBit/Python/Node 版本，并对相同代码跑格式、检查、Wasm GC 和 JS、三个示例、生成差分、Edge 和 ZIP 消费测试。作业配置 20 分钟上限。

Windows 使用 PowerShell 写生成 CSV，Python 显式读取 UTF-8 或 UTF-8 BOM。Edge 使用隔离临时配置和下载目录。消费测试使用 Python 路径组件及显式 UTF-8，并以 subprocess 参数列表执行 MoonBit。日志和归档写入 _build。

本机 Native 编译计划在发现 cl.exe 或 clang-cl.exe 前失败，未运行 Native 测试。JS 和 Wasm GC 各 18/18。初始化动作依赖 Runner 的 C++ 工具和 SDK。 [MoonBit Windows Native 文档](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html)

获授权后，仅将候选 HEAD 推送至公开仓库的 codex/v020-windows-validation 分支，按 push 触发验证，记录实际 checkout SHA 和 Windows Native 两步日志。Pages 部署的 push 触发仅限 main。无需推送 main、打标签或创建 Release。 [GitHub push 工作流说明](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#push)
