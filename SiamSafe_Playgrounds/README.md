# SiamSafe for Swift Playgrounds

เปิด `SiamSafe_swftpg.swiftpm` ด้วย Swift Playgrounds แล้วกด Run
บน iPad ให้แตก ZIP ในแอป Files ก่อน จากนั้นแตะไฟล์ .swiftpm
ต้องใช้ iPadOS 17 ขึ้นไปและ Swift Playgrounds รุ่นที่รองรับ Swift tools 5.9
บน Mac ใช้ Swift Playgrounds รุ่นปัจจุบันที่รองรับแพ็กเกจนี้


## การรันบนอุปกรณ์ / Running on your device

**แนะนำให้ build และรันแอปบนอุปกรณ์ของคุณเอง เพราะ Preview / Live Preview อาจไม่ทำงานหรือแสดงผลไม่ครบ**
บน iPad ให้เปิดแพ็กเกจใน Swift Playgrounds แล้วกด Run เพื่อทดลองแอปบน iPad โดยตรง
หากต้องการติดตั้งบน iPhone จาก Mac ให้เปิดแพ็กเกจใน Xcode เลือกอุปกรณ์ของคุณ ตั้งค่า Signing แล้วกด Run
หาก Preview ค้างหรือไม่แสดงผล ไม่ได้หมายความว่าแอป build ไม่ผ่าน ให้ลองรันแอปจริงแทน

**Build and run the app on your own device. Preview / Live Preview may be unavailable or may not display the app correctly.**
On iPad, open the package in Swift Playgrounds and tap Run. To run on an iPhone from a Mac, open the package in Xcode, select your device, configure signing, and run the app.


## สิ่งที่ปรับ
- คัดลอก source และ Assets จาก SiamSafe เป็น App Playground แยกต่างหาก
- ใช้ Firestore REST API เชื่อม project siamsafe / collection events เดิม
- รองรับอ่าน active/resolved, เพิ่ม และลบ event ผ่าน Security Rules เดิม
- ไม่มี Firebase SDK dependencies จึงไม่ต้องดาวน์โหลด packages เพิ่ม
- ใช้ ToolbarItem .principal แทน .title เพื่อรองรับระบบรุ่นก่อนหน้า
- ตัด #Preview macros ออกจากสำเนา ใช้ Run/Live Preview ของ Playgrounds
- ระบุ capability ตำแหน่งและการเชื่อมต่อเครือข่าย
- ไฟล์ GoogleService-Info.plist และ Item.swift เก็บจากต้นฉบับ แต่ exclude จาก target เพราะไม่ใช้

## ข้อมูลจริงและโหมดออฟไลน์
ค่าเริ่มต้นอ่าน/เขียนฐานข้อมูลจริง การเพิ่มหรือลบในแอปนี้ส่งผลต่อข้อมูลที่แอป iPhone และเว็บใช้ด้วย
หากต้องการสาธิตแบบออฟไลน์ ให้เปลี่ยน `RuntimeEnvironment.usesMockServices` เป็น `true` ใน Sources/SiamSafeApp.swift
โหมดนี้ใช้ข้อมูลตัวอย่างและแผนที่จำลอง

REST ใช้สิทธิ์ unauthenticated เช่นเดียวกับแอปเดิมที่ไม่มี Firebase Auth
ถ้า Rules ต้องการ login หรือเปิด App Check enforcement ต้องเพิ่ม authentication/App Check ที่เหมาะสม ไม่ควรเปิด Rules เพื่อข้ามข้อจำกัด
หากอ่านไม่สำเร็จ จะแสดงข้อความผิดพลาดและปุ่มลองใหม่ สามารถ pull-to-refresh ได้
ไม่มี realtime listener หรือ offline Firestore cache; ใช้การโหลด/รีเฟรชตาม flow เดิม

## ผลตรวจ
- Type-check source ทั้งหมดสำหรับ iOS Simulator ผ่าน
- Swift Playgrounds บน Mac เปิดแพ็กเกจและรายงาน Build succeeded without issues
- ทดสอบอ่านข้อมูลจริงผ่าน REST สำเร็จ และ decode document จริงได้
- ตรวจ timestamp แบบ fractional, integer coordinates และ malformed document ผ่าน
- ไม่ได้ทดสอบเพิ่ม/ลบกับฐานจริงเพื่อหลีกเลี่ยงแก้ข้อมูลระหว่างตรวจ
- ยังไม่ได้ทดสอบบน iPad ของผู้รับ หรือยืนยันการรัน UI ทุกหน้าบน Playgrounds
