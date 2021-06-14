# Command List

```sh
# 라우트 주소를 변경 한다.
openstack router set --external-gateway public --fixed-ip subnet=public-subnet,ip-address=192.168.77.130 dongmook-router

# 프로젝트 리소트 쿼터를 설정 한다. 디폴트 값 확인
openstack quota set --instances 50 ccambo
openstack quota set --cores 50 ccambo
openstack quota set --volume 50 ccambo
openstack quota set --volumes 50 ccambo
openstack quota set --cores 50 cloudjeong
openstack quota set --volumes 50 cloudjeong
openstack quota set --instances 50 cloudjeong
openstack quota set --cores 50 dongmook
openstack quota set --ram 70 dongmook
openstack quota set --ram 7000 dongmook
openstack quota set --ram 70000 dongmook

```
