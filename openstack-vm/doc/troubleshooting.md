# Openstack Troubleshooting

## ssh key 분실시 접속 방법
- openstack 관리자가 kvm manager를 통해서 해당 인스탄스의 볼륨을 복구 디스크 이미지 볼륨으로 마운트 해서 복구 할 수 있다.
```sh
# step01. 해당 인스탄스를 shutdown
# step02. 해당 인스탄스의 볼륨 ID값을 저장
# step03. kvm manager에서 복구 디스크 이미지로 해당 인스탄스의 볼륨을 붙여서 복구 디스크 생성
# stop04. 아래 명령어로 root의 비번을 변경 한다.
lsblk
mkdir disk
mount /dev/sda1 ./disk

# root 권한 사용
chroot ./disk
passwd
```
<span style="color:blue">asdfasdf</span>
<font color ="red">asdfasdf</font>


# 참조
> [Ubuntu 암호 재설정](https://www.thefastcode.com/ko-krw/article/reset-your-ubuntu-password-easily-from-the-live-cd)