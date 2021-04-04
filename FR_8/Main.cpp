//---------------------------------------------------------------------------

#include <vcl.h>
#include <windows.h>
#pragma hdrstop



#include "FprnM45Proxy.h"
#include "../../kkm_def.h"
//---------------------------------------------------------------------------
#define EXC(c) try { c; } catch(Exception* e) { throw ShortString(e->Message); }
#define EXOLE(c) try { OleCheck(c); } catch(Exception* e) { throw ShortString(e->Message); }
#define EX_START(name) AnsiString tr_ex_start_name = name; try {
#define EX_END } catch(Exception* e) { throw ShortString(tr_ex_start_name + ": " + e->Message); } catch(ShortString s) { throw s; }catch(...) { throw ShortString(tr_ex_start_name + ": " + "Uknown C++ exception"); }
//---------------------------------------------------------------------------
AnsiString MyCurrToStr(Currency value) {
  return FloatToStrF(value, ffFixed, 8, 2);
}
#define CurrToStr MyCurrToStr

//---------------------------------------------------------------------------
void show(const AnsiString& msg)
{
  MessageBox(0, msg.c_str(), "ККМ АТОЛ драйвер", MB_OK);
}



//---------------------------------------------------------------------------
class KKM_ATOL : public KKM_INTRF_EGAIS {
private:
  IFprnM45Proxy* f_drv;

  KKM_DOC_TYPE f_doc_type;
  AnsiString f_passw;
  bool f_in_session;
  int f_session;
  unsigned f_last_tick;
  bool f_need_sep;
  Currency f_doc_sum;

  void assert_res(int value) {
    while(value == -3807 && f_drv->Mode == 1) {
      show("Пожалуйста вставте бумагу в ККМ");
      value = f_drv->CancelCheck();
      if(value != -3807) throw Exception("Пробейте чек еще раз!");
    }
    if(value != 0)
      throw ShortString("Ошибка ККМ: " + IntToStr(value));
  }

  AnsiString strf(const AnsiString& s, const AnsiString& p_rs) {
    AnsiString str = s;
    AnsiString rs = p_rs;
    int max_len = f_drv->CharLineLength;
    int maxr_len = max_len - 6;
    if(max_len < 10) throw Exception("strf: Invalid max_len");
    int rs_len = rs.Length();
    if(rs_len >= maxr_len) {
      rs.SetLength(maxr_len - 3);
      rs += "...";
      rs_len = rs.Length();
    }
    int req_len = max_len - rs_len;
    if(str.Length() > req_len) {
      str.SetLength(req_len - 3);
      str += "...";
    }
    else while(str.Length() < req_len) str += ' ';
    str += rs;
    return str;
  }

public:
  KKM_ATOL() {


    f_drv = 0;
    f_in_session = false;
    f_last_tick = 0;
    f_need_sep = false;
    f_doc_sum = 0;
    f_session = 0;
  }


  virtual ~KKM_ATOL() {

  }
  virtual void init(const ShortString& port_name, const ShortString& passw) {
    EX_START("init")

    
    f_doc_type = kdt_uknown;
    f_passw = passw;
    /*if(AnsiString(port_name).Trim() != "")
      throw Exception("Параметр порт игнорируется!!! Всегда используется ткущее логическое устройство общего драйвера!!!");*/
    CoInitialize(0);
    f_drv = new IFprnM45Proxy();
    f_drv->init();
    /*if(CoCreateInstance(CLSID_FprnM45, 0, CLSCTX_INPROC_SERVER, IID_IFprnM45,
      (void**)&f_drv) != S_OK)
      throw Exception("CoCreateInstance failed!!!");*/

    f_drv->DeviceEnabled = 1;

    assert_res(f_drv->GetDeviceMetrics());


    if(f_drv->UType != 1) {
      f_drv->DeviceEnabled = 0;
      throw Exception("Данное устройство не является ККМ!!!");
    }

    assert_res(f_drv->GetStatus());
    f_in_session = f_drv->SessionOpened;
    f_session = f_drv->Session;
    EX_END
  }
  virtual void de_init() {
    EX_START("de_init")
      if(f_drv) {
        try { f_drv->DeviceEnabled = 0; } catch(...) { ; }
        f_drv->Release();
        delete f_drv;
        f_drv = 0;
        //CoUninitialize();
      }
    EX_END
  }

  virtual unsigned get_max_major() {
    return 1;
  }

  virtual unsigned get_max_minor() {
    return 11;
  }

  virtual ShortString get_device_name() {
    EX_START("get_device_name")
      assert_res(f_drv->GetDeviceMetrics());
      switch(f_drv->UModel) {
        case 0: return ShortString("ККМ ЭЛВЕС-МИКРО-Ф");
        case 13: return ShortString("ККМ Триум-Ф");
        case 14: return ShortString("ККМ ФЕЛИКС-Р Ф");
        case 15: return ShortString("ККМ ФЕЛИКС-Р К");
        case 16: return ShortString("ККМ МЕРКУРИЙ-140");
        case 17: return ShortString("ККМ МЕРКУРИЙ-114.1Ф");
        case 18: return ShortString("ККМ ШТРИХ-ФР-Ф");
        case 19: return ShortString("ККМ ЭЛВЕС-МИНИ-ФР-Ф");
        case 20: return ShortString("ККМ МЕРКУРИЙ-114.1Ф «ТОРНАДО»");
        case 24: return ShortString("ФЕЛИКС-РК");
        case 27: return ShortString("ФЕЛИКС-3СК");
        case 30: return ShortString("FPrint-02K");
        case 31: return ShortString("FPrint-03K");
        case 32: return ShortString("FPrint-88K");
        case 33: return ShortString("FPrint-5200K");
        case 35: return ShortString("BIXOLON-01K");
        case 37: return ShortString("PayVKP-80K");
        case 38: return ShortString("PayPPU-700K");
        case 39: return ShortString("PayCTS-2000K");
        default: return ShortString("Неизвестная модель оборудования");
      }
    EX_END


  }

  virtual ShortString get_serial_number() {
    EX_START("get_serial_number")
      assert_res(f_drv->GetStatus());
      f_session = f_drv->Session;
      return ShortString(AnsiString(WideString(f_drv->SerialNumber)));
    EX_END
  }

  virtual ShortString get_reg_number() {
    return ShortString("");
  }

  virtual void set_check_header(unsigned index, const ShortString& value, bool bold) {
    EX_START("set_check_header")
      throw Exception("Not implemented!!!");
    EX_END
  }

  virtual void set_date_time(TDateTime value) {
    EX_START("set_date_time")
      throw Exception("Not implemented!!!");
    EX_END
  }

  virtual void open_session(const ShortString& cashier, unsigned short cash_no) {
    EX_START("open_session")

      f_drv->set_Password(WideString(AnsiString(f_passw)));
      f_drv->Mode = 1;
      assert_res(f_drv->SetMode());
      AnsiString str = AnsiString("Кассир: ") +  AnsiString(cashier);
      if(str.Length() > f_drv->CharLineLength) {
        str.SetLength(f_drv->CharLineLength - 3);
        str += "...";
      }
      f_drv->set_Caption(WideString(str));
      //f_drv->set_CaptionPurpose(89);

      //f_drv->SetCaption();

      f_drv->TestMode = 0;
      assert_res(f_drv->OpenSession());
      f_in_session = true;
      assert_res(f_drv->GetStatus());
      f_in_session = f_drv->SessionOpened;
      f_session = f_drv->Session;
    EX_END
  }

  virtual void close_session() {
    EX_START("close_session")
      print_report(krt_z1);
    EX_END
  }

  virtual void start_doc(KKM_DOC_TYPE doc_type, int section, int id, const ShortString& klerk_name);
  /*{
    EX_START("start_doc")
      if(doc_type == kdt_saling || doc_type == kdt_cash_back_good) {
        f_drv->set_Password(WideString(AnsiString(f_passw)));
        f_drv->Mode = 1;
        assert_res(f_drv->SetMode());
        f_doc_type = doc_type;
        f_drv->TestMode = 0;
        f_drv->CheckType = (doc_type == kdt_saling) ? 1 : 3;
        if(doc_type == kdt_saling)
          assert_res(f_drv->OpenCheck());
      } else if(doc_type == kdt_cash_back_storno) {
        f_doc_sum = 0;
        f_doc_type = doc_type;
        f_drv->Mode = 2;
        assert_res(f_drv->SetMode());
        // assert_res(f_drv->PrintHeader());
        print_string("СТОРНО возврат", true);
      } else if(doc_type == kdt_cash_input || doc_type == kdt_cash_output) {
        f_doc_type = doc_type;
        f_drv->Mode = 1;
        assert_res(f_drv->SetMode());
      }
      else throw Exception("Неправильный тип документа: " + IntToStr(doc_type));
    EX_END
  } */

  virtual void cancel_doc() {
    EX_START("cancel_doc")
      try {
        if(f_doc_type == kdt_saling || f_doc_type == kdt_cash_back_good) {
          f_drv->TestMode = 0;
          f_drv->TypeClose = 0;
          assert_res(f_drv->CancelCheck());
        }
      } __finally {
        try { de_init(); } catch(...) { ; }
        try { init("", f_passw); } catch(...) { ; }
      }
    EX_END
  }

  virtual void end_doc() {
    EX_START("end_doc")
      if(f_doc_type == kdt_saling || f_doc_type == kdt_cash_back_good) {
        f_drv->TestMode = 0;
        f_drv->TypeClose = 0;
        assert_res(f_drv->CloseCheck());
      } else if(f_doc_type == kdt_cash_back_storno) {
        print_string(strf("ИТОГО:", CurrToStr(f_doc_sum)).c_str(), true);
        assert_res(f_drv->PrintFooter());
        f_drv->Mode = 1;
        assert_res(f_drv->SetMode());
      }
      f_doc_type = kdt_uknown;
    EX_END
  }

  virtual void add_good(const ShortString& name, double price, double quantity, int tax_group) {
    EX_START("add_good")
      throw Exception("Not implemented!!!");
    EX_END
  }

  virtual void absolute_correction(double value) {
    EX_START("add_good")
      throw Exception("Not implemented!!!");
    EX_END
  }

  virtual void percent_correction(int value) {
    EX_START("add_good")
      throw Exception("Not implemented!!!");
    EX_END
  }

  virtual void tender(KKM_TENDER_TYPE t, double sum, const ShortString& card_num,
    const ShortString& card_auth) {
    EX_START("tender")
      if(f_doc_type == kdt_saling || f_doc_type == kdt_cash_back_good) {
        f_drv->TestMode = 0;
        f_drv->Summ = Currency(sum);
        f_drv->TypeClose = t;
        /* show(FloatToStr(sum));
        show(CurrToStr(f_drv->Summ));
        show(IntToStr(f_drv->TypeClose)); */
        assert_res(f_drv->Payment());
      } else if(f_doc_type == kdt_cash_back_storno) {
      } else if(f_doc_type == kdt_cash_input) {
        f_drv->TestMode = 0;
        f_drv->Summ = sum;
        assert_res(f_drv->CashIncome());
      } else if(f_doc_type == kdt_cash_output) {
        f_drv->TestMode = 0;
        f_drv->Summ = sum;
        assert_res(f_drv->CashOutcome());
      } else throw Exception("Invalid document type!!!");
    EX_END
  }

  virtual void text_line(const ShortString& line) {
    EX_START("text_line")
      f_drv->TextWrap = 1;
      f_drv->set_Caption(WideString(AnsiString(line)));
      assert_res(f_drv->PrintString());
    EX_END
  }

  virtual void print_report(KKM_REPORT_TYPE type) {
    EX_START("print_report")
      try {
        if(type == krt_x1 || type == krt_section) f_drv->Mode = 2;
        else if(type == krt_z1) f_drv->Mode = 3;
        else throw Exception("Invalid report type: " + IntToStr(type));
        assert_res(f_drv->SetMode());
        if(type == krt_x1) f_drv->ReportType = 2;
        else if(type == krt_z1) f_drv->ReportType = 1;
        else if(type == krt_section) f_drv->ReportType = 7;
        assert_res(f_drv->Report());
        if(type == krt_z1 || type == krt_z1) f_in_session = false;
        assert_res(f_drv->GetStatus());
        f_in_session = f_drv->SessionOpened;
        f_session = f_drv->Session;
      } __finally {
        /*f_drv->Mode = 1;
        assert_res(f_drv->SetMode());*/
      }
    EX_END
  }

  virtual void open_drawer() {
    EX_START("open_drawer")
      assert_res(f_drv->OpenDrawer());
    EX_END
  }

  virtual void test_printer() {
    EX_START("test_printer")
      throw Exception("Not implemented!!!");
    EX_END
  }

  virtual bool in_session() {
    /*DWORD tick = GetTickCount();
    if(tick < f_last_tick || (f_last_tick + 2500) < tick) {
      try {
        f_last_tick = tick;
        assert_res(f_drv->GetStatus());
        f_in_session = f_drv->SessionOpened;
      } catch(...) {
        ;
      }
    } */
    return f_in_session;
  }

  virtual bool test(ShortString& msg) {
    return true;
  }

  virtual void repeat_document() {
    EX_START("repeat_document")
      throw Exception("Функция повтора документа не поддерживается!!!");
    EX_END
  }

  virtual void edit_set() {
    EX_START("repeat_document")
      assert_res(f_drv->ShowProperties());
    EX_END
  }

  virtual void add_good_ex(const ShortString& name, double act_price, double quantity,
    int tax_group, int discont, int doc_discont, bool additive,
    const ShortString& discont_name) {
    EX_START("add_good_ex")
      throw Exception("Not implemented!!!");
    EX_END
  }

  virtual void print_string(const char* str) {
    EX_START("print_string")
      f_drv->TextWrap = 1;
      f_drv->set_Caption(WideString(AnsiString(str)));
      assert_res(f_drv->PrintString());
    EX_END
  }

  virtual unsigned __int64 get_support_version() const {
    return KKM_SUPPORT_ARM2_EX_DISCONT | KKM_WRITE_HF | KKM_LW_PRINT | KKM_CUT | KKM_DRAW_BMP | KKM_HEADER_BEFOR_START | KKM_EGAIS | KKM_OFD;
  }

  virtual Currency add_good_ex2(__int64 code, const ShortString& name, const Currency& price, const double& quantity,
    int tax_group, bool print_discont, const ShortString& discont_code,
    const ShortString& discont_name, int discont_percent) {
    EX_START("add_good_ex2")
      //MessageBox(0, "Here", "Debug", MB_OK);
      const AnsiString sep = AnsiString::StringOfChar('=', f_drv->CharLineLength);
      if(f_need_sep || print_discont) print_string(sep.c_str());
      f_need_sep = false;
      Currency act_price = make_discount(price, discont_percent);
      Currency amount = round2(act_price * quantity);
      f_drv->TestMode = 0;
      f_drv->TextWrap = 1;
      if(f_doc_type == kdt_saling || f_doc_type == kdt_cash_back_good) {
        f_drv->set_Name(WideString(name));
        f_drv->Quantity = quantity;
        f_drv->Price = act_price;

        f_drv->TaxTypeNumber = 0;

        if (tax_group==1)
        {
                f_drv->Department = 0;
        }
        else{
                f_drv->Department = tax_group;
        }
        if(f_doc_type == kdt_saling)
          assert_res(f_drv->Registration());
        else {
          f_drv->EnableCheckSumm = 0;
          assert_res(f_drv->Return());
        }
      } else if(f_doc_type == kdt_cash_back_storno) {
        f_doc_sum += amount;
        print_string(AnsiString(name).c_str(), false);
        AnsiString pstr = FloatToStr(quantity) + "X" + CurrToStr(act_price) + "=" + CurrToStr(amount);
        while(pstr.Length() < f_drv->CharLineLength)
          pstr = AnsiString(' ') + pstr; 
        print_string(pstr.c_str(), false);
      } else throw Exception("Unsupported document type!!!");
      if(print_discont) {
        print_string(strf(Trim(discont_name),
          IntToStr(discont_percent) + "%").c_str());
        f_need_sep = true;
      }
      return amount;
    EX_END
  }

  virtual void print_disco_card(const ShortString& discont_code,
    const ShortString& discont_name, int discont_percent) {
    EX_START("print_disco_card")
      const AnsiString sep = AnsiString::StringOfChar('=', f_drv->CharLineLength);
      print_string(sep.c_str());
      print_string(strf("ДИСКОНТНАЯ КАРТА", "").c_str(), true);
      print_string(strf("№" + discont_code + "-" +Trim(discont_name), IntToStr(discont_percent) + "%").c_str());
    EX_END
  }

  virtual void print_string(const char* str, bool bold) {
    EX_START("print_string")
      print_string(str);
    EX_END
  }

  virtual unsigned get_protect_num() {
    EX_START("get_protect_num")
      assert_res(f_drv->GetStatus());
      try {
        return StrToInt(AnsiString(WideString(f_drv->SerialNumber)));
      } catch(EConvertError& ) {
        return 0;
      }
    EX_END
  }
  void absolute_correction(Currency sum) {
    EX_START("void absolute_correction(Currency sum)")
        f_drv->TestMode = 0;
        f_drv->Summ = -sum;
        f_drv->Destination = 0;
        assert_res(f_drv->SummDiscount());
    EX_END
  }

  unsigned int get_document_number() {
    EX_START("unsigned int get_document_number()")
        f_drv->RegisterNumber = 19;
        f_drv->CheckType = 1;
        f_drv->TypeClose = 0;
        assert_res(f_drv->GetRegister());
        return f_drv->CheckNumber;
    EX_END
  }

  virtual int get_session_number()
  {
    EX_START("int get_session_number()")
        try {
           //      ShowMessage("get_session_number()");
          int mode =f_drv->Mode;
          f_drv->Mode = 1;
          assert_res(f_drv->SetMode());

          f_drv->RegisterNumber = 21;

          assert_res(f_drv->GetRegister());

          int session = f_drv->Session;

          f_drv->Mode = mode;
          assert_res(f_drv->SetMode());

          return session;

        } catch(...) {
          return -1;
        }
    EX_END
  }

  virtual void start_text_report() {
    EX_START("virtual void start_text_report()")
      //assert_res(f_drv->BeginDocument());
    EX_END
  }

  virtual void end_text_report() {
    EX_START("virtual void end_text_report()")
      //assert_res(f_drv->EndDocument());
    EX_END
  }

  virtual void set_config_file(const ShortString& file_name)
  {
    EX_START("virtual void set_config_file(const ShortString& file_name)")
      throw Exception("Not implemented");
    EX_END
  }

  virtual void set_dialog_handle(HWND handle)
  {
    EX_START("virtual void set_dialog_handle(HWND handle)")
      throw Exception("Not implemented");
    EX_END
  }

  virtual int select_kkm_dlg(HWND parent, bool set_selected_kkm)
  {
    EX_START("virtual int select_kkm_dlg(HWND parent, bool set_selected_kkm)")
      throw Exception("Not implemented");
    EX_END
  }

  virtual void set_active_kkm(int number)
  {
    EX_START("virtual void set_active_kkm(int number)")
      throw Exception("Not implemented");
    EX_END
  }

  virtual int get_active_kkm() const
  {
    EX_START("virtual int get_active_kkm() const")
      throw Exception("Not implemented");
    EX_END
  }

  virtual Currency add_good_ex3(__int64 code, const ShortString& name, const Currency& price, const double& quantity,
    int tax_group, bool print_discont, const ShortString& discont_code,
    const ShortString& discont_name, int discont_percent, int section)
  {
    EX_START("virtual Currency add_good_ex3")
      if(!tax_group) tax_group = section;
      else if(section && tax_group != section)
        throw Exception("Номер отдела должен соападать с номером налоговой группы");
    EX_END
    return add_good_ex2(code, name, price, quantity, tax_group, print_discont,
      discont_code, discont_name, discont_percent);
  }

  virtual void close_session_ex(REPORT_STRUCT* params)
  {
    print_report_ex(krt_z1, params);
  }

  virtual void print_report_ex(KKM_REPORT_TYPE t, REPORT_STRUCT* params)
  {
    EX_START("virtual void print_report_ex(KKM_REPORT_TYPE t, REPORT_STRUCT* params)")
      if(params && (t == krt_z1 || t == krt_z2)) {
        f_drv->RegisterNumber = 1;
        f_drv->CheckType = 1;
        assert_res(f_drv->GetRegister());
        params->sum_sale = f_drv->Summ;

        f_drv->CheckType = 2;
        assert_res(f_drv->GetRegister());
        params->sum_ret_sale = f_drv->Summ;

        /*f_drv->CheckType = 3;
        assert_res(f_drv->GetRegister());
        params->sum_null_sale = f_drv->Summ;*/
        params->sum_null_sale =0 ;

        f_drv->RegisterNumber = 3;
        f_drv->CheckType = 1;
        for(int i = 0; i < 4; i++) {
          f_drv->TypeClose = i;
          assert_res(f_drv->GetRegister());
          params->sum_pay[i] = f_drv->Summ;
        }

        f_drv->CheckType = 2;
        for(int i = 0; i < 4; i++) {
          f_drv->TypeClose = i;
          assert_res(f_drv->GetRegister());
          params->sum_ret_pay[i] = f_drv->Summ;
        }

        f_drv->RegisterNumber = 4;
        assert_res(f_drv->GetRegister());
        params->sum_income = f_drv->Summ;

        f_drv->RegisterNumber = 5;
        assert_res(f_drv->GetRegister());
        params->sum_outcome = f_drv->Summ;

        f_drv->RegisterNumber = 6;
        f_drv->CheckType = 1;
        assert_res(f_drv->GetRegister());
        params->count_sale = f_drv->Count;

        f_drv->CheckType = 2;
        assert_res(f_drv->GetRegister());
        params->count_ret_sale = f_drv->Count;

        /*f_drv->CheckType = 3;
        assert_res(f_drv->GetRegister());
        params->count_null = f_drv->Count;*/
        params->count_null = 0;

        f_drv->RegisterNumber = 8;
        assert_res(f_drv->GetRegister());
        params->income_count = f_drv->Count;

        f_drv->RegisterNumber = 9;
        assert_res(f_drv->GetRegister());
        params->outcome_count = f_drv->Count;

        f_drv->RegisterNumber = 10;
        assert_res(f_drv->GetRegister());
        params->nal = f_drv->Summ;

        f_drv->RegisterNumber = 11;
        assert_res(f_drv->GetRegister());
        params->profit = f_drv->Summ;


        f_drv->RegisterNumber = 12;
        f_drv->OperationType = 0;
        assert_res(f_drv->GetRegister());

        params->session_sale_sum = f_drv->Summ;


        /*f_drv->RegisterNumber = 13;
        f_drv->OperationType = 0;
        assert_res(f_drv->GetRegister());

        params->non_null_summ_sale = f_drv->Summ;*/
        params->non_null_summ_sale = 0;


        f_drv->RegisterNumber = 22;
        assert_res(f_drv->GetRegister());
        params->serial = AnsiString(f_drv->SerialNumber);

        params->generated = true;
      }
    EX_END
    print_report(t);
    if(params && (t == krt_z1 || t == krt_z2) && params->generated) {
      params->session_number = get_session_number();
    }
  }

    void write_table(/*int table_number,int field_number,*/int rownumber,AnsiString value){
      f_drv->set_Password(WideString(AnsiString(f_passw)));
      f_drv->Mode = 4;

      int ret = f_drv->SetMode();


      if(ret ==-3822){
        ShowMessage("Ошибка ККМ -3822: Текущая смена превысила 24 часа:");
        return;
      }

      assert_res(ret);
      


      f_drv->set_CaptionPurpose(rownumber);
      f_drv->set_Caption(WideString(value));
     // f_drv->set_MaxCaptionLength(48);
      f_drv->SetCaption();
      //ShowMessage(IntToStr(value.Length())+" "+IntToStr(rownumber)+" "+value+" "+IntToStr(f_drv->get_MaxCaptionLength()));
      //f_drv->TestMode = 0;
  }




    AnsiString center_str(AnsiString name){

        AnsiString value = name;
        value = value.Trim();
        int l =CheckLenghtGet()-value.Length();

        if (l>0){
                int lm=(int)l/2;
                AnsiString space="";
                for (int i=0;i<lm;i++)
                {
                        space+=" ";
                }

                value = space+value;
        }
        return value;

    }



    void WriteHeader(const ShortString& name,int row){
        //write_table_int(1,1,4,1);
        EX_START("WriteHeader")


        AnsiString value = center_str(AnsiString(name));

        /*AnsiString value = name;
        value = value.Trim();
        int l =CheckLenghtGet()-value.Length();

        if (l>0){
                int lm=(int)l/2;
                AnsiString space="";
                for (int i=0;i<lm;i++)
                {
                        space+=" ";
                }

                value = space+value;
        }*/

        write_table(72 + row-1,value);

        EX_END

  }
  void WriteFooter(const ShortString& name,int row){

        EX_START("WriteFooter")

        /*AnsiString value = name;
        value = value.Trim();
        int l =CheckLenghtGet()-value.Length();

        if (l>0){
                int lm=(int)l/2;
                AnsiString space="";
                for (int i=0;i<lm;i++)
                {
                        space+=" ";
                }

                value = space+value;
        }*/

        AnsiString value = center_str(AnsiString(name));
        


        write_table(69 + row-1,value);
        /*if (!f_print_footer) {
                write_table(1,4,1,"1");
                f_print_footer = true;
        }


        write_table(4,1,row,name); */
        EX_END
  }
  void WriteTable(const ShortString& name,int table_number,int field_number,int row){
  }

  unsigned int CheckLenghtGet(){
        //return 48;
        return f_drv->CharLineLength;
  }
  virtual void OpenConnection(bool beep){
  }
  virtual void CloseConnection(){
  }

  virtual void Cut(int type){
        if (type==0){
                f_drv->FullCut();
        }else{
                f_drv->PartialCut();
        }
  }

  virtual bool WriteHeader2Header(){
        return true;
  }


  //---------------------------------------------------------------------------

  AnsiString  drawfile_get(AnsiString name){

        int pos_root =  name.Pos("<logo>");
        if (!pos_root){
                return name;
        }


        AnsiString tag = "logo_atol";

        int pos_node = name.Pos("<"+tag+">");

        if (!pos_node) throw Exception("tag <"+tag+"> is not found");

        int pos_node_end = name.Pos("</"+tag+">");

        if (!pos_node_end) throw Exception("tag </"+tag+"> is not found");

        int pos_begin = pos_node+tag.Length()+2;

        AnsiString nnn = name.SubString(pos_begin,pos_node_end-pos_begin);

        return nnn;

  }


  //---------------------------------------------------------------------------

  void DrawFromFile(const ShortString& name,int Alignment,int LeftMargin){
        EX_START("DrawFromFile")

                AnsiString file_name = drawfile_get(AnsiString(name));
                if (file_name=="") return;
                /*f_drv->PrintPurpose = 3;
                f_drv->StreamFormat  =5;
                f_drv->OutboundStream = "00 ff 00 ff 00 ff 00 ff 00 ff 00 ff";
                f_drv->Count = 1;
                f_drv->PrintBitmap();*/

                f_drv->BarcodeType= 0;
                f_drv->Scale=100;
                f_drv->FileName = WideString(file_name);

                f_drv->Height = 0;

                f_drv->LeftMargin = LeftMargin;

                f_drv->Alignment = 0;

                assert_res(f_drv->PrintBitmapFromFile());


        EX_END
  }


  virtual bool HeaderBeforStart(){
        return false;
  }

  virtual void EgaisDraw(const ShortString& url,const ShortString& sign){
        EX_START("EgaisDraw")

        f_drv->FileName = WideString("");
        f_drv->BarcodeType= 84;
        f_drv->Barcode = WideString(url);
        f_drv->PrintBarcodeText = 2;


        try{
                f_drv->LeftMargin = 0;
                f_drv->Scale=500;
                f_drv->Alignment =1;

                assert_res(f_drv->PrintBarcode());
        }__finally{
                f_drv->Scale=0;
                f_drv->Alignment =0;
        }



        f_drv->TextWrap = 1;
        f_drv->set_Caption(WideString(" "));
        assert_res(f_drv->PrintString());

        f_drv->TextWrap = 1;
        f_drv->set_Caption(WideString(url));
        assert_res(f_drv->PrintString());

        f_drv->TextWrap = 1;
        f_drv->set_Caption(WideString(" "));
        assert_res(f_drv->PrintString());

        f_drv->TextWrap = 1;
        f_drv->set_Caption(WideString(sign));
        assert_res(f_drv->PrintString());


        EX_END
  }
  void OFDSetPhone (const ShortString& phone){
      EX_START("OFDSetPhone")
            f_drv->AttrNumber = 1008;
            f_drv->AttrValue = WideString(phone);
            assert_res(f_drv->WriteAttribute());

      EX_END
  }
  void OFDSetEmail (const ShortString& email){
      EX_START("OFDSetEmail")
            f_drv->AttrNumber = 1008;
            f_drv->AttrValue = WideString(email);
            assert_res(f_drv->WriteAttribute());

      EX_END
  }
};

void KKM_ATOL::start_doc(KKM_DOC_TYPE doc_type, int section, int id,
    const ShortString& klerk_name) {
    EX_START("start_doc")
      if(doc_type == kdt_saling || doc_type == kdt_cash_back_good) {
        f_drv->set_Password(WideString(AnsiString(f_passw)));
        f_drv->Mode = 1;
        assert_res(f_drv->SetMode());
        f_doc_type = doc_type;
        f_drv->TestMode = 0;
        f_drv->CheckType = (doc_type == kdt_saling) ? 1 : 3;
        if(doc_type == kdt_saling)
          assert_res(f_drv->OpenCheck());
      } else if(doc_type == kdt_cash_back_storno) {
        f_doc_sum = 0;
        f_doc_type = doc_type;
        f_drv->Mode = 2;
        assert_res(f_drv->SetMode());
        // assert_res(f_drv->PrintHeader());
        print_string("СТОРНО возврат", true);
      } else if(doc_type == kdt_cash_input || doc_type == kdt_cash_output) {
        f_doc_type = doc_type;
        f_drv->Mode = 1;
        assert_res(f_drv->SetMode());
      }
      else throw Exception("Неправильный тип документа: " + IntToStr(doc_type));
    EX_END
  }



//---------------------------------------------------------------------------
KKM_INTRF_EGAIS* _export get_1_1() {
  return new KKM_ATOL();
}
//---------------------------------------------------------------------------
void _export rel(KKM_INTRF_1_1* obj) {
  delete obj;
}
//---------------------------------------------------------------------------
#pragma argsused
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void* lpReserved)
{
  return 1;
}
//---------------------------------------------------------------------------
