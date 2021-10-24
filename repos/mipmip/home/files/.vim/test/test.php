<?php
namespace Lingewoud\LwtplCcv\Controller;

/***************************************************************
 *
 *  Copyright notice
 *
 *  (c) 2017 Pim Snel <pim@lingewoud.nl>, Lingewoud
 *
 *  All rights reserved
 *
 *  This script is part of the TYPO3 project. The TYPO3 project is
 *  free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  The GNU General Public License can be found at
 *  http://www.gnu.org/copyleft/gpl.html.
 *
 *  This script is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  This copyright notice MUST APPEAR in all copies of the script!
 ***************************************************************/

function hex2dec($color = "#000000"){
  $tbl_color = array();
  $tbl_color['R']=hexdec(substr($color, 1, 2));
  $tbl_color['G']=hexdec(substr($color, 3, 2));
  $tbl_color['B']=hexdec(substr($color, 5, 2));
  return $tbl_color;
}

function px2mm($px){
  return $px*25.4/72;
}

function txtentities($html){
  $trans = get_html_translation_table(HTML_ENTITIES);
  $trans = array_flip($trans);
  return strtr($html, $trans);
}


/**
 * DocumentController
 */
class PvaController extends \TYPO3\CMS\Extbase\Mvc\Controller\ActionController {

  /**
   *
   * @var   \Lingewoud\lwtplCcv\Service\HTML2FPDF
   * @inject
   */
  //  protected $pdf;



  /**
   * action initialize
   *
   * @return void
   */
  public function initializeAction() {
  }

  /**
   * ACTIONS (public) functions
   */

  /**
   * action index
   *
   * @return string The rendered view
   */
  public function indexAction() {
  }

  /**
   * action downloadPdfButton
   *
   * @return string The rendered view
   */
  //public function downloadPdfButtonAction() {
  //}

  /**
   * action downloadPdfButton
   *
   * @return string The rendered view
   */
  public function downloadPdfHandlerAction() {


    $sourceFile = $this->settings['eLearning']['pdfCert']['sourceFile'];
    $namePosX = $this->settings['eLearning']['pdfCert']['namePosX'];
    $namePosY = $this->settings['eLearning']['pdfCert']['namePosY'];
    $orgPosX = $this->settings['eLearning']['pdfCert']['orgPosX'];
    $orgPosY = $this->settings['eLearning']['pdfCert']['orgPosY'];
    $datePosX = $this->settings['eLearning']['pdfCert']['datePosX'];
    $datePosY = $this->settings['eLearning']['pdfCert']['datePosY'];
    $fontSize = $this->settings['eLearning']['pdfCert']['fontSize'];
    $fontColorR = $this->settings['eLearning']['pdfCert']['fontColorR'];
    $fontColorG = $this->settings['eLearning']['pdfCert']['fontColorG'];
    $fontColorB = $this->settings['eLearning']['pdfCert']['fontColorB'];
    //   $filePath = $this->settings['eLearning']['pdfCert']['filePath'];
    //   $filenameBase = $this->settings['eLearning']['pdfCert']['filenameBase'];


    $cover      = $this->settings['pvapdf']['cover'] =     "typo3conf/ext/lwtpl_ccv/Resources/Private/PDF/pva-zelfscan-cover.pdf";
    $back       = $this->settings['pvapdf']['cover'] =     "typo3conf/ext/lwtpl_ccv/Resources/Private/PDF/pva-zelfscan-back.pdf";
    $filename   = $this->settings['pvapdf']['filename'] =  "advies-persoonlijke-veiligheid.pdf";

    $file = mb_ereg_replace("([^\w\s\d\-_~,;\[\]\(\).])", '', $filename);
    $file = mb_ereg_replace("([\.]{2,})", '', $file);

    $pdf = $this->pdf;
    $pdf = new HTMLPDF('P','mm','A4','titel','',false);
    // other options
    $this->from='UTF-8';         // input encoding
    $this->to='windows-1252';               // output encoding
    $this->useiconv=true;            // use iconv
    $this->bi=true;                   // support bold and italic tags

    /* cover */
    $pdf->AddPage();
    $pdf->setSourceFile(PATH_site . $cover);


    $tplIdx = $pdf->importPage(1);
    $pdf->useTemplate($tplIdx, 0, 0, 211);

    // Read text file
    $pdf->AddPage();
    $pdf->SetFont('Profile','',12);
    $pdf->WriteHTML($this->_convert(stripslashes($_POST['var1'])),$this->bi);

    /* back */
    $pdf->AddPage();
    $pdf->setSourceFile(PATH_site . $back);

    $tplIdx = $pdf->importPage(1);
    $pdf->useTemplate($tplIdx, 0, 0, 211);

    $pdf->Output($file,'D');
    exit;
  }

  function _convert($s) {
    if ($this->useiconv)
      return iconv($this->from,$this->to,$s);
    else
      return $s;
  }

}


/************************************/
/* class PDF                        */
/************************************/
class HTMLPDF extends \HeikoHardt\HhdevFpdi\Fpdi
{
  protected $B;
  protected $I;
  protected $U;
  protected $HREF;
  protected $fontList;
  protected $issetfont;
  protected $issetcolor;

  #MyLine
  function Ln($h, $caller=''){
    //    $this->Write(5,$caller.">l:".$h);
    parent::Ln($h);
  }


  function WriteHTML($html,$bi)
  {
    $this->h1counter = 1;
    //remove all unsupported tags
    $this->bi=$bi;

    if ($bi)
      $html=strip_tags($html,"<a><img><p><brx><font><tr><blockquote><h1><h2><h3><h4><pre><red><blue><ul><li><hr><b><i><u><strong><em><kader>");
    else
      $html=strip_tags($html,"<a><img><p><brx><font><tr><blockquote><h1><h2><h3><h4><pre><red><blue><ul><li><hr><kader>");

    if ($this->debug) { echo $html; exit; }

    $html = str_replace("\n",' ',$html); //replace carriage returns with spaces
    $html = str_replace('&trade;','™',$html);
    $html = str_replace('&copy;','©',$html);
    $html = str_replace('&euro;','€',$html);
    $html = str_replace('&nbsp;',' ',$html);

    $a=preg_split('/<(.*)>/U',$html,-1,PREG_SPLIT_DELIM_CAPTURE);
    $skip=false;

    $this->normalX = $this->GetX();

    foreach($a as $i=>$e)
    {
      if (!$skip) {
        if($this->HREF)
          $e=str_replace("\n","",str_replace("\r","",$e));
        if($i%2==0)
        {
          // new line
          if($this->PRE)
            $e=str_replace("\r","\n",$e);
          else
            $e=str_replace("\r","",$e);
          //Text
          if($this->HREF) {
            $this->PutLink($this->HREF,$e);
            $skip=true;
          } else
            $this->Write(6,stripslashes(txtentities($e)));
        } else {
          //Tag
          if (substr(trim($e),0,1)=='/')
            $this->CloseTag(strtoupper(substr($e,strpos($e,'/'))));
          else {
            //Extract attributes
            $a2=explode(' ',$e);
            $tag=strtoupper(array_shift($a2));
            $attr=array();
            foreach($a2 as $v) {
              if(preg_match('/([^=]*)=["\']?([^"\']*)/',$v,$a3))
                $attr[strtoupper($a3[1])]=$a3[2];
            }
            $this->OpenTag($tag,$attr);
          }
        }
      } else {
        $this->HREF='';
        $skip=false;
      }
    }
  }

  function OpenTag($tag,$attr)
  {
    //Opening tag
    switch($tag){
    case 'STRONG':
    case 'B':
      if ($this->bi)
        $this->SetStyle('B',true);
      else
        break;
    case 'H1':
      if($this->h1counter > 1) {
      }
      $this->h1counter++;
      $this->Ln(10);
      //$this->SetStyle('B',true);
      $this->SetFontSize(22);
      break;
    case 'H2':
      $this->Ln(15);
      $this->SetFontSize(18);
      //$this->SetStyle('B',true);
      break;
    case 'H3':
      $this->Ln(15);
      //$this->SetStyle('B',true);
      $this->SetFontSize(16);
      break;
    case 'H4':
      $this->Ln(15);
      $this->SetFontSize(14);
      if ($this->bi)
        $this->SetStyle('B',true);
      break;
    case 'KADER':
      $this->SetFontSize(22);
      $this->SetTextColor(194,8,25);
      break;
    case 'PRE':
      $this->SetFont('Courier','',11);
      $this->SetFontSize(11);
      $this->SetStyle('B',false);
      $this->SetStyle('I',false);
      $this->PRE=true;
      break;
    case 'RED':
      break;
    case 'BLOCKQUOTE':
      $this->Ln(3);
      break;
    case 'BLUE':
      break;
    case 'I':
    case 'EM':
      if ($this->bi)
        $this->SetStyle('I',true);
      break;
    case 'U':
      $this->SetStyle('U',true);
      break;
    case 'A':
      $this->HREF=$attr['HREF'];
      break;
    case 'IMG':
      if(isset($attr['SRC']) && (isset($attr['WIDTH']) || isset($attr['HEIGHT']))) {
        if(!isset($attr['WIDTH'])) $attr['WIDTH'] = 0;
        if(!isset($attr['HEIGHT'])) $attr['HEIGHT'] = 0;

        $this->imageHeader = true;
        $this->imageHeaderArray = Array(
          'src' => $attr['SRC'],
          'pos1' => 0,
          'pos2' => 0,
          'pos3' => 210
        );
        $this->AddPage();

        //$this->Image($attr['SRC'],0,0,210);
        //$this->Ln(33);
      }
      break;
    case 'UL':
      $this->SetLeftMargin($this->normalX+3);
      break;
    case 'LI':
      $this->Ln(7);
      $this->setX($this->normalX+3);
      $this->Write(6,chr(127));
      $this->SetLeftMargin($this->normalX+6);
      break;
    case 'TR':
      $this->Ln(7);
      $this->PutLine();
      break;
    case 'BR':
      $this->Ln(3,'br');
      break;
    case 'P':
      $this->Ln(6);
      $this->SetFontSize(12);
      break;
    case 'HR':
      $this->PutLine();
      break;
    case 'FONT':
      if (isset($attr['FACE']) && in_array(strtolower($attr['FACE']), $this->fontlist)) {
        $this->SetFont(strtolower($attr['FACE']));
        $this->issetfont=true;
      }
      break;
    }
  }

  function CloseTag($tag)
  {

    $tag = str_replace('/','',$tag);
    //Closing tag
    if ($tag=='H1' || $tag=='H2' || $tag=='H3' || $tag=='H4'){
      $this->Ln(1);
      $this->SetFont('Profile','',12);
      $this->SetFontSize(12);

      $this->SetStyle('B',false);
    }

    if ($tag=='KADER'){
      $this->SetTextColor(0,0,0);
    }
    if ($tag=='PRE'){
      $this->SetFont('Profile','',12);
      $this->SetFontSize(12);
      $this->PRE=false;
    }
    if ($tag=='RED' || $tag=='BLUE')
      if ($tag=='BLOCKQUOTE'){
        $this->Ln(3);
      }
    if($tag=='STRONG')
      $tag='B';
    if($tag=='EM')
      $tag='I';
    if((!$this->bi) && $tag=='B')
      $tag='U';
    if($tag=='B' || $tag=='I' || $tag=='U')
      $this->SetStyle($tag,false);
    if($tag=='A')
      $this->HREF='';
    if($tag=='UL')
      $this->SetLeftMargin($this->normalX+3);
    if($tag=='LI')
      $this->SetLeftMargin($this->normalX);
    if($tag=='FONT'){
      if ($this->issetcolor==true) {
        $this->SetTextColor(0,0,0);
      }
      if ($this->issetfont) {
        $this->SetFont('Profile','',12);
        $this->issetfont=false;
      }
    }
  }

  function Footer()
  {
    return;
    //Go to 1.5 cm from bottom
    $this->SetY(-15);
    //Select Arial italic 8
    $this->SetFont('Profile','',8);
    //Print centered page number
    $this->SetTextColor(0,0,0);
    $this->Cell(0,4,'Page '.$this->PageNo().'/{nb}',0,1,'C');
    $this->SetTextColor(0,0,180);
    $this->Cell(0,4,'Created by HTML2PDF / FPDF',0,0,'C',0,'http://hulan.info/blog/');
    $this->mySetTextColor(-1);
  }

  function Header()
  {
    if($this->imageHeader){
      $this->Image($this->imageHeaderArray['src'],
        $this->imageHeaderArray['pos1'],
        $this->imageHeaderArray['pos2'],
        $this->imageHeaderArray['pos3']);
      $this->Ln(35);
    }

    return;
  }

  function SetStyle($tag,$enable)
  {
    $this->$tag+=($enable ? 1 : -1);
    $style='';
    foreach(array('B','I','U') as $s) {
      if($this->$s>0)
        $style.=$s;
    }
    $this->SetFont('',$style);
  }

  function PutLink($URL,$txt)
  {
    //Put a hyperlink
    $this->SetTextColor(0,143,197);
    $this->Write(6,$txt,$URL);
    $this->mySetTextColor(-1);
  }

  function PutLine()
  {
    $this->Ln(2);
    $this->Line($this->GetX(),$this->GetY(),$this->GetX()+187,$this->GetY());
    $this->Ln(3);
  }

  function mySetTextColor($r,$g=0,$b=0){
    static $_r=0, $_g=0, $_b=0;

    if ($r==-1)
      $this->SetTextColor($_r,$_g,$_b);
    else {
      $this->SetTextColor($r,$g,$b);
      $_r=$r;
      $_g=$g;
      $_b=$b;
    }
  }

  function PutMainTitle($title) {
    if (strlen($title)>55)
      $title=substr($title,0,55)."...";
    $this->SetTextColor(33,32,95);
    $this->SetFontSize(20);
    $this->SetFillColor(255,204,120);
    $this->Cell(0,20,$title,1,1,"C",1);
    $this->SetFillColor(255,255,255);
    $this->SetFontSize(12);
    $this->Ln(5);
  }

  function PutMinorHeading($title) {
    $this->SetFontSize(12);
    $this->Cell(0,5,$title,0,1,"C");
    $this->SetFontSize(12);
  }

  function PutMinorTitle($title,$url='') {
    $title=str_replace('http://','',$title);
    if (strlen($title)>70)
      if (!(strrpos($title,'/')==false))
        $title=substr($title,strrpos($title,'/')+1);
    $title=substr($title,0,70);
    $this->SetFontSize(16);
    if ($url!='') {
      $this->SetStyle('U',false);
      $this->SetTextColor(0,0,180);
      $this->Cell(0,6,$title,0,1,"C",0,$url);
      $this->SetTextColor(0,0,0);
      $this->SetStyle('U',false);
    } else
      $this->Cell(0,6,$title,0,1,"C",0);
    $this->SetFontSize(12);
    $this->Ln(4);
  }





} // class PDF
