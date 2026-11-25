# v0.2.0 跨平台发布包审计

## 远程基线

已通过的冻结提交为 d13268237601f7ecde3ffffe145a21ed388bb5e2。两个作业使用同一提交的工作流、打包脚本和过滤规则，均记录 Moon 0.1.20261119（738607b）。Windows 使用 windows-latest 与 MSVC，Linux 使用 ubuntu-latest，两端测试与解包消费通过。Pages 工作流独立部署，只归档 Studio 站点，未为该候选 CI 留存发布包。 [Windows](https://github.com/jojochensmart-lab/moonpicross/actions/runs/45611887770/job/139197256706) · [Linux](https://github.com/jojochensmart-lab/moonpicross/actions/runs/45611887770/job/139197257419)

| 历史包 | SHA256 |
|---|---|
| Windows 原包 | 9541f21c52b6b2cc51464f4f1ba9b4a4edd1c095fba00d04b7c2c0a90573a069 |
| Linux 原包 | 1874e84107c5cd96c7830aa0c793fd7bdf916ec8d817762e341c93eb37f26496 |
| 本地冻结原包 | aff5c83bd7fd7353ef5cc2e470ff12ef1d982997d5dbb271718b93a068ec4f35 |
| 本地冻结规范包 | 73b6607973797d29497d92695851899a0afad4125207c022c81bb6d26f49272c |

已复核本地冻结文件清单及校验记录。历史两端日志各列出相同的 44 个成员，Actions API 记录 0 个产物。历史三端逐文件对账为 C，尚没有可核实的历史差异文件清单。此前本地控制实验确认换行足以改变整体哈希，但无法确定这次实际历史差异的原因。 [此前 ZIP 实验](V020_ZIP_CONSISTENCY_AUDIT.md)

## 新流程与独立对账

CI 在 Native、其他目标、旧包自检及示例全部通过后生成三份独立 ZIP。Moon 原包保留原始字节；源码包统一已知文本行尾、成员顺序、日期和权限，使用 ZIP_STORED；Studio ZIP 仅含 HTML、样式、脚本、编译的 engine.js 及 LICENSE。manifest 记录提交 SHA、Moon/Python/Node 版本、操作系统和 Runner 镜像信息、实际核对的脚本 Git blob 哈希。每个成员记录原始字节数、SHA256 和显式 LF 归一化后的 SHA256。未上传日志、配置目录、缓存或申报书。上传只在消费和浏览器检查成功后执行，缺文件或上传错误使工作流失败。Linux 浏览器路径依据 Ubuntu Runner 镜像的 Google Chrome 配置，仍待远程实测。 [GitHub artifact 操作](https://github.com/actions/upload-artifact) · [Ubuntu Runner 镜像](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md)

对账入口：

~~~sh
python scripts/release-evidence.py compare --windows <windows-artifact-dir> --linux <linux-artifact-dir> --local <same-SHA-local-dir>
~~~

A 表示成员路径及逐文件原始字节一致，整体 ZIP 字节是否相同另有字段。B 逐项报告行尾、编译产物、未解释内容和 ZIP 元数据差异，仍保留原始哈希。C 表示缺包或证据不完整，包括不一致的构建 SHA、脚本来源或 Runner Moon 版本。对账前逐包验 CRC、重算 manifest，之后可使用 package_smoke 的 --external 和 --canonical 分别进行新解包消费。重新打包时，从最终验证 SHA 生成新的本地对照组，不能把旧冻结 SHA 的 ZIP 当作同一检出。若本地 Moon 与远端的版本不同，报告显式保留这个差异。

## 本地演练与未完成项

Windows 本地验证 JS、Wasm GC 各 18/18，Python Oracle 15,745 组。Moon 原包和规范化包均通过新项目的两后端消费。Studio ZIP 解包后通过桥接、真实 Edge 文件往返和刷新。一次相同输入重复生成及输入顺序、时间、权限、压缩参数扰动均通过。模拟三端分别覆盖 A、仅行尾的 B，以及真实缺少远端输入的 C。模拟的 CRLF 原包可被独立消费，规范化后与本地一致。这些是本机实验。

新 Runner 尚未执行。远端 Windows/Linux 各自 ZIP、真实差异原因、三端逐文件对账、跨系统规范化字节一致及远端新包独立消费均待验证。最终本地三包及 SHA256 清单写入 _build/v020-r16/final-local/，本地日志和控制实验在其父目录。

冻结重打包时，敏感模式扫描把报告中 Git SHA 的 11 个连续数字误识别成手机号。已限于手机号规则排除完整的 40/64 位十六进制哈希，其他敏感模式照常扫描，独立电话号码仍被拒绝。
