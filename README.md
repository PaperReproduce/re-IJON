# reproduce-ijon

> 复现 IJON 论文实验的最小步骤，按顺序执行即可。

## 第一步：准备源码
1. 克隆本仓库后初始化子模块：
   ```bash
   git submodule update --init --recursive
   ```
2. 子模块说明：
   - `repos/ijon`：AFL+IJON 主工程。
   - `repos/ijon-data`：论文实验数据（Mario、TPM、Maze 等）。

## 第二步：构建基础镜像并自检
1. 构建 `reproduce-ijon:latest`：
   ```bash
   ./scripts/build_image.sh
   ```
2. 在容器内运行 AFL 自检，确认工具链没问题：
   ```bash
   ./scripts/run_selftest.sh reproduce-ijon:latest
   ```

## 第三步：准备 Mario 环境并启动 fuzz
1. 下载原版 `Super Mario Bros. (JU) (PRG0) [!].nes`，然后：
   ```bash
   ./scripts/build_mario_image.sh --rom /path/to/Super\ Mario\ Bros.\ (JU)\ (PRG0)\ [!].nes
   ```
   - 脚本会验证 MD5 (`811b027eaf99c2def7b933c5208636de`) 并将 ROM 复制到 `external/mario/roms/mario.nes`。
   - 如何下载呢？
      - Google 上搜索 `811b027eaf99c2def7b933c5208636de`， 然后多翻几个页面就有了。
2. 可选：运行一个 1 小时的 fuzz demo（默认 3600 秒，可用 `DEMO_SECONDS=600` 覆盖）：
   ```bash
   ./scripts/run_mario_demo.sh reproduce-ijon-mario:latest
   ```
   - 脚本会在容器里用 `seed/a` 初始化输入，并调用 `/workspace/repos/ijon/afl-fuzz`。

## 其他说明
- 若需要对 `SuperMarioBros-C` 做额外修改，请在 `patches/` 下追加补丁，`docker/Dockerfile.mario` 构建时会自动应用。
- 想要复现 TPM 或 Maze，可直接参考 `repos/ijon-data` 对应子目录的脚本，方法与 Mario 类似：在基础镜像中复制数据、构建目标、启动 AFL。
