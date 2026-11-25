# v0.2.0 Windows Runner 验证报告

2026-11-25（北京时间）。**通过。** 候选提交已达到此前本地验收报告列出的 Windows Native 发布条件。

- 候选分支为 [codex/v020-windows-validation](https://github.com/jojochensmart-lab/moonpicross/tree/codex/v020-windows-validation)，SHA 为 `077e40d84e68c9dac353fb80f49d90bf90680ae4`。推送前本地 main 干净，账号通过 GitHub API 确认为 jojochensmart-lab。
- 由候选分支的 push 触发，运行记录和 Windows 日志均核对候选 SHA。Windows 与 Linux 两个作业均成功。 [完整运行](https://github.com/jojochensmart-lab/moonpicross/actions/runs/45604621651) · [Windows 作业](https://github.com/jojochensmart-lab/moonpicross/actions/runs/45604621651/job/139172158604)

| Windows Runner 检查 | 实测结果 |
|---|---|
| MoonBit 工具链 | 0.1.20261119（738607b），MSVC 开发环境初始化成功 |
| Native 构建 | moon build --target native 成功，随后实际运行 Native 测试 |
| Native 测试 | 18/18 通过，0 失败 |
| Wasm GC | 检查和构建成功，18/18 通过 |
| JS | 18/18 通过，Studio 桥接测试通过 |
| Oracle 与生成 | 原始 Oracle、141 组行候选、三项示例和两批种子的独立唯一性验证均通过 |
| Edge | 离线交互、磁盘文件选择、下载落盘和重导入，及 20×20 操作与刷新均通过 |
| 归档与消费 | Runner ZIP 43 项，CRC、清单、安全筛查和隔离消费均通过。Runner ZIP SHA256 为 bb34704a2df222a12b69058a2df9f5cf111f52e897cf766132950211eeef9ede。 |

无失败项。GitHub 在运行中提示部分 Action 的 Node.js 20 运行时已弃用，实际由 Node.js 24 执行。归档在本地与 Runner 均通过内容检查，两处 ZIP 的 SHA256 不同，本轮未核实字节级重现，也未据此推断差异原因。

完整 Windows 日志、摘要和运行元数据分别保存于 `_build/v020-windows-run-45604621651/windows-full.log`、`windows-key.log` 和 `run.json`。

复核后，本地 main 仍是上述候选 SHA，远程 main 仍是 `253a51b9d47657b5560e1b1be6f4a4e69c0b17f6`，远程 v0.1.0 标签仍指向 `2dc7550d90e6b5878ffb1500fffef4676e24969e`。仅推送了候选分支。这份报告只在本地更新，未提交或推送。正式发布操作需另行授权。
