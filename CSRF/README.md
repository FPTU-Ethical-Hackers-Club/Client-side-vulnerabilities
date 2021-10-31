# Cross-site request forgery 

### I. LÝ THUYẾT:

#### 1) Tìm hiểu về CSRF:

- **Cross-site Request Forgery** (viết tắt là **CSRF**) là một lỗ hổng cho phép attacker có thể buộc cho victim phải thực hiện các hành động không theo chủ ý của họ bằng cách phá vỡ chính sách cùng nguồn gốc (SOP), 

- Một cuộc tấn công **CSRF** thành công giúp cho attacker đánh lừa browser của người dùng gửi request, buộc web server phải thực hiện request gửi lên một cách hợp pháp (vì người gửi request chính là victim chứ không phải là attacker), do đó số lượng victim có thể lên đến con số rất lớn. 

  ![CSRF](https://portswigger.net/web-security/images/cross-site%20request%20forgery.svg)

#### 2) Khai thác CSRF:

###### a) Kịch bản tấn công:

- Một ứng dụng web có chức năng cho phép user thay đổi địa chỉ email dùng để xác thực tài khoản. Khi user **Alice** thực hiện thao tác này, tức là **Alice** sẽ tạo ra một request như sau để gửi đến web server:

  ```http
  POST /email/change_email HTTP/1.1
  Host: vulnerable.com
  Content-Type: application/x-www-form-urlencoded
  Content-Length: 30
  Cookie: session=yvthwsztyeQkAPzeQ5gHgTvlyxHfsAfE
  
  email=alice@hotmail.com
  ```

-  Chức năng này của ứng dụng web thỏa mãn 3 yếu tố để attacker có thể tấn công CSRF:

  \+ Có yếu tố **sửa** và **xóa**: sau khi thay đổi địa chỉ email, attacker có thể trigger chức năng thay đổi mật khẩu bằng email và chiếm toàn bộ quyền kiểm soát tài khoản của user **Alice**.

  \+ Quản lý **session** dựa trên **cookie**: ứng dụng web này sử dụng cookie **session** để xác định user nào đã tạo ra request. Điều này có nghĩa là bất kỳ request nào có chứa cookie này đều được duyệt bởi web server, do không có thêm bất cứ một token hay cơ chế nào để đảm bảo mỗi request gửi đi là duy nhất (request validating).

  \+ Các **parameter** trong **request** quá **dễ đoán**: giả sử ứng dụng web này chức năng thay đổi mật khẩu, khi đó, ngoài parameter **new_password** là có thể thay đổi tùy ý ra thì request yêu cầu phải có có thêm một parameter nữa là **old_password ** (unpredictable parameter) buộc attacker phải đoán. Nhưng trong chức năng thay đổi email xác thực này, ngoài parameter là **email** ra chúng ta không có thêm bất cứ một **unpredictable parameter** nào.

- Với các điều kiện thuận lợi như trên, attacker có thể xây dựng một trang phishing với nội dung HTML như sau:

  ```html
  <html>
    <body>
      <form action="https://vulnerable.com/email/change_email" method="POST">
        <input type="hidden" name="email" value="pwned@evil-user.net" />
      </form>
      <script>
        document.forms[0].submit();
      </script>
    </body>
  </html>
  ```

  Giả sử trang web **vulnerable.com** không sử dụng **SOP**, khi victim **Alice** truy cập vào trang phishing này, những điều sau sẽ xảy ra:

  \+ Trang phishing sẽ gửi một request đến **vulnerable.com**. Thường thì URL của trang phishing sẽ được đặt bên trong **vulnerable.com**, nếu victim **Alice** đã log in vào **vulnerable.com** thì cookie **session** sẽ được sinh ra, do đó browser sẽ tự động điền cookie này của **Alice** vào request (giả sử trang web không sử dụng biện pháp [SameSite cookies](https://portswigger.net/web-security/csrf/samesite-cookies)), làm cho web server tưởng rằng đây là request của **Alice**.

  \+ Từ đó, web server sẽ xử lý request này, thay đổi email xác thực của **Alice** thành **pwned@evil-user.net** theo đúng ý của attacker.                                                                                                                                                              

###### b) Cách khai thác:

Ngoài cách khai thác sử dụng một trang phishing như kịch bản tấn công, chúng ta có những cách khai thác khác như sử dụng **XSS** để tấn công **CSRF**: cách này hiệu quả và tỉ lệ thành công cao hơn so với việc tạo ra một trang phishing, vì dùng trang phishing để gửi request có thể gặp những rào cản như **SOP**, [SameSite cookies](https://portswigger.net/web-security/csrf/samesite-cookies) hay **CSRF Token**, còn khi dùng **XSS** để tấn công **CSRF** chúng ta có thể dễ dàng bypass hết các rào cản trên.

#### 3) Cách phòng chống CSRF:

- Sử dụng **SOP**, [SameSite cookies](https://portswigger.net/web-security/csrf/samesite-cookies).

- Tại mỗi phiên làm việc của user trên ứng dụng web, ta tạo một **CSRF Token**, lưu nó vào session. Ví dụ:

  ```php
  session_start();
  if(!isset($_SESSION['student']) || !$_SESSION['student'] || !isset($_SESSION['user'])){
    header('Location: login.php');
  } else{
    if(empty($_SESSION['key'])){
          $_SESSION['key'] = bin2hex(random_bytes(32));
    }
    $csrf = hash_hmac('sha256',$_SESSION['user'],$_SESSION['key']);
    $_SESSION['csrf'] = $csrf;
  }
  ```

  Sau đó nhét **CSRF Token** này vào một hidden input của form như sau:

  ```html
  <input type="hidden" name="csrf" value="<?php echo $csrf;?>">
  ```
