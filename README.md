# อธิบาย
นี่คือ Shell Script สำหรับ DDNS (Dynamic DNS) ใช้สำหรับโดเมนที่โฮสต์ด้วย BIND9
# วิธีใช้
**คำแนะนำสามารถใช้ได้กับ Linux Debian base นอกนั้นอื่น ๆ ลองปรับเปลี่ยนกันเอาเอง**

สมมุติว่าได้ติดตั้ง nsupdate ไว้แล้ว (ปกติมาพร้อมกับ BIND)

1 แก้ไขไฟล์ที่ ```/etc/bind/named.conf```

เพิ่มข้อความต่อไปนี้
```
include "/etc/bind/key/*.key"; หาก BIND ที่เวอร์ชั่นที่ใช้อยู่ "สามารถ" ใช้ Wildcard ได้
include "/etc/bind/key/keylist"; หาก BIND ที่เวอร์ชั่นที่ใช้อยู่ "ไม่" สามารถใช้ Wildcard ได้
```

2 สร้างไดเรกทอรีชื่อ ```key```

```
mkdir /etc/bind/key
```
และ chmod
```
# เพื่อความปลอดภัยของคีย์
chmod 750 /etc/bind/key
```
3 สร้างคีย์ TSIG HMAC SHA256 SHA384 SHA512 เลือกเอาที่ชอบ ๆ
```
cd /etc/bind/key
tsig-keygen -a HMAC-SHA512 KEYNAME >> key
```
4 ตั้งค่าสิทธิ์ของคีย์ที่โซน ```/etc/bind/named.conf.local```
```
zone "example.net" in {
	. . .
	update-policy {
    // A AAAA TXT TLSA SSHFP SOA NS ...
		grant KEYNAME name example.net A TXT;

	};
	. . .
};

```
5 คัดลอกสำเนาคีย์อย่างไรก็ได้ให้ปลอดภัยไปยังเครื่อง Client
6 ทำตามคำแนะนำในไฟล์ ```ddns.sh```
