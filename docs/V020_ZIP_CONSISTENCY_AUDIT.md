# v0.2.0 ZIP 一致性审计

| 原包来源 | 文件数 | ZIP SHA256 | 实物 |
|---|---:|---|---|
| 本地 | 43 | e91d3cbae4d9c795de3921077f2af4d8e7989b37e757bbf091ea35bbd7c954c0 | 已保留 |
| Windows Runner | 43 | bb34704a2df222a12b69058a2df9f5cf111f52e897cf766132950211eeef9ede | 仅 CI 日志 |
| Linux Runner | 43 | 07aa0e28a666bbc7f42716763298867f18de03e5e51e456f3a528eb8766a5462 | 仅 CI 日志 |

GitHub API 显示该次运行上传了 0 个 artifacts。两个 Runner 的日志清单转换路径分隔符后，均与本地原包的 43 个文件名一致。日志列出的顺序与本地 ZIP 中央目录顺序不同，不能据此判定历史 ZIP 内部次序。历史 Runner 原包的逐文件字节、哈希、时间戳和压缩参数无法从日志恢复。 [候选 CI](https://github.com/jojochensmart-lab/moonpicross/actions/runs/45604621651)

## 同一提交控制实验

固定提交 077e40d84e68c9dac353fb80f49d90bf90680ae4，在隔离目录强制使用 LF 和 CRLF 两种检出，用本机 Moon 0.1.20261028 打包。

| 对照 | 相同成员路径 | 原始字节或 SHA256 不同 | 归一行尾后差异 |
|---|---:|---:|---:|
| 本地原包 / LF 重建 | 43 | 11 | 0 |
| 本地原包 / CRLF 重建 | 43 | 43 | 0 |
| LF / CRLF 重建 | 43 | 43 | 0 |

LF 重建的 ZIP SHA256 为 f07c2ab1a99d6ef8b18803d4067742a4cb158d11b956ed2d16a45ca8b84f4a1b，CRLF 重建为 6d54da726eb6c4c1ee7d80cd55c7004de488704c76e91df3b8227ca1d7128a8d。本地可解包样本的路径分隔符、中央目录顺序、1980-01-01 时间戳、Deflate 方法、平台标识和权限一致，成员只差行尾及衍生的压缩前后长度。对 CRLF 检出再执行 Oracle 和格式化，11 个 core 文件改回 LF，生成第三种 ZIP 哈希 26fad6d08d73a87d33de9206863735a553d5f6f2b09f9f7dab4f282cfcfc49f2。

因此，换行差异足以改变源码相同的 ZIP 哈希。Runner 使用 Moon 0.1.20261119，原 ZIP 不可取得，历史差异的确切归因仍待取得原包确认。逐文件解压字节与 SHA256、元数据差异和两份 Runner 清单均保存在 _build/v020-release-evidence 下。

## 确定性源码分发 ZIP

tests/release_zip.py 保留全部安全成员，仅将已知 UTF-8 文本的 CRLF 统一到 LF。名称排序、时间和权限固定，ZIP_STORED 排除压缩器版本影响。原本地包、LF 和 CRLF 重建包的规范化输出字节一致，SHA256 均为 c0b24a51c4bdd1b5bf2662ea6ce1d452c68690e5132e1ec2b22c5037323f1733。

冻结前的 44 文件准备包也通过重复构建，以及行尾、时间、成员顺序、权限和压缩级别扰动测试。规范化输出均为 b8e01271d3078fa7736c312dcdc618b18558a662d7c19962960180fff759b5a5。该次 Moon 原包和规范化 ZIP 均通过 CRC、路径、隐私检查及 JS/Wasm GC 全新消费测试。本轮实测限本机。此 ZIP 用于独立源码分发，Mooncakes 原包和浏览器包各走原有流程。

冻结提交的重建结果与哈希另存于 _build/v020-final-freeze/FINAL_FREEZE.md。
