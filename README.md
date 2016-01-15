# HsProgressHUD 

one can dismiss ProgressHUD with message 、warn、error、success、loading，and warn and error never dismiss

简单使用 pod 'HsProgressHUD' '1.0.0'

```c
- (IBAction)progressShowAction:(id)sender {
[HsProgressHUD showWithTitle:@"客户请稍后,数据马上奉上"];
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
[HsProgressHUD showWithErrorTitle:@"功提交成功提交成功"];
});
}
- (IBAction)progressDismissAction:(id)sender {
[HsProgressHUD dismiss];
}
- (IBAction)progressSuccessAction:(id)sender {
[HsProgressHUD showWithSucessTitle:@"提交成功提交成功提交成功提交成功提交成功提交成功提交成功提交成功提交成功提交成功提交成功提交成功提交成功提交成功提交成功提交成功提交成功提交成功提交成功提交成功"];
}
- (IBAction)progressErrorAction:(id)sender {
[HsProgressHUD showWithErrorTitle:@"提交失败提交失败提交失败提交失败"];
}
- (IBAction)progressWarnAction:(id)sender {
[HsProgressHUD showWithWarnTitle:@"提交失败提交失败提交失败提交失败"];
}

```