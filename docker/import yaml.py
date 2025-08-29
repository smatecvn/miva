import yaml
import subprocess

def update_netplan(file_path, interface, new_ip, new_gateway, new_dns):
    try:
        # Đọc file YAML
        with open(file_path, 'r') as file:
            config = yaml.safe_load(file)

        # Kiểm tra interface tồn tại
        if 'ethernets' not in config['network'] or interface not in config['network']['ethernets']:
            raise ValueError(f"Interface {interface} không tồn tại trong file {file_path}")

        # Cập nhật IP, gateway, DNS
        eth_config = config['network']['ethernets'][interface]
        eth_config['dhcp4'] = False
        eth_config['addresses'] = [new_ip]
        eth_config['routes'] = [{'to': 'default', 'via': new_gateway}]
        eth_config['nameservers'] = {'addresses': new_dns}

        # Ghi lại file YAML
        with open(file_path, 'w') as file:
            yaml.dump(config, file, default_flow_style=False, sort_keys=False)
        # Áp dụng netplan
        with open("/root/mgwp/network/netplan.apply", "w") as f:
            f.write("True\n")
        print("Netplan applied successfully.")
    except Exception as ex:
        print(f"Error update_netplan: {ex}")


def update_netplan_yaml(file_path, new_apn=None, new_metric=None):
    try:
        with open(file_path, 'r') as file:
            config = yaml.safe_load(file)

        if new_apn:
            config['network']['modems']['cdc-wdm0']['apn'] = new_apn
        if new_metric:
            config['network']['modems']['cdc-wdm0']['dhcp4-overrides']['route-metric'] = new_metric

        with open(file_path, 'w') as file:
            yaml.dump(config, file, default_flow_style=False, sort_keys=False)
    except Exception as ex:
        print(f"Error update_netplan_yaml: {ex}")

update_netplan(
    '/etc/netplan/01-netcfg.yaml',  # Đường dẫn file netplan
    'eth0',                         # Interface
    '192.168.10.120/24',            # IP mới
    '192.168.10.1',                # Gateway mới
    ['8.8.8.8', '8.8.4.4']         # DNS mới
)