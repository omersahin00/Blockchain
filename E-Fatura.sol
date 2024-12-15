// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ElektrikFaturasi {
    address public sozlesmeSahibi;
    uint256 public sonOdemeTarihi;

    struct Fatura {
        address musteriAdresi;
        uint256 enerjiKullanim;
        uint256 enerjiBirimFiyati;
        uint256 odenecekTutar;
        uint256 sonOdeme;
        bool odendi;
    }

    mapping(address => Fatura) private faturalar;

    modifier sadeceSahip() {
        require(msg.sender == sozlesmeSahibi, "Sadece sozlesme sahibi bu islemi yapabilir.");
        _;
    }

    modifier sadeceMusteri() {
        require(faturalar[msg.sender].musteriAdresi == msg.sender, "Sadece fatura sahibi bu islemi yapabilir.");
        _;
    }

    constructor(uint256 _sure) {
        sozlesmeSahibi = msg.sender;
        sonOdemeTarihi = _sure;
    }

    function FaturaEkle(
        address _musteriAdresi,
        uint256 _enerjiKullanim,
        uint256 _enerjiBirimFiyati
    ) public sadeceSahip {
        require(faturalar[_musteriAdresi].musteriAdresi == address(0), "Bu adrese zaten bir fatura tanimlanmis.");
        uint256 hesaplananTutar = _enerjiKullanim * _enerjiBirimFiyati;

        faturalar[_musteriAdresi] = Fatura({
            musteriAdresi: _musteriAdresi,
            enerjiKullanim: _enerjiKullanim,
            enerjiBirimFiyati: _enerjiBirimFiyati,
            odenecekTutar: hesaplananTutar,
            sonOdeme: sonOdemeTarihi,
            odendi: false
        });
    }

    function FaturayiGor() public view sadeceMusteri returns (
        uint256 _enerjiKullanim,
        uint256 _enerjiBirimFiyati,
        uint256 _toplamTutar,
        uint256 _sonOdeme,
        string memory _odemeDurumu,
        bool _odendi
    ) {
        Fatura memory fatura = faturalar[msg.sender];
        require(fatura.musteriAdresi != address(0), "Fatura bulunamadi.");
        string memory odemeDurumu = block.timestamp > fatura.sonOdeme ? "Cezali" : "Normal";
        uint256 toplamTutar = block.timestamp > fatura.sonOdeme ? fatura.odenecekTutar * 2 : fatura.odenecekTutar;

        return (
            fatura.enerjiKullanim,
            fatura.enerjiBirimFiyati,
            toplamTutar,
            fatura.sonOdeme,
            odemeDurumu,
            fatura.odendi
        );
    }

    function OdemeYap() public payable sadeceMusteri {
        Fatura storage fatura = faturalar[msg.sender];
        require(!fatura.odendi, "Fatura zaten odendi.");
        uint256 toplamTutar = block.timestamp > fatura.sonOdeme ? fatura.odenecekTutar * 2 : fatura.odenecekTutar;
        require(msg.value == toplamTutar, "Yanlis tutar gonderildi.");

        fatura.odendi = true;
        fatura.odenecekTutar = 0;
    }

    function Transfer() public sadeceSahip {
        payable(sozlesmeSahibi).transfer(address(this).balance);
    }
}
