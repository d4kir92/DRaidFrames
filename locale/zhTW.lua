-- zhTW Traditional Chinese

local AddOnName, DRaidFrames = ...

function DRaidFrames:DRFLangzhTW()
	local lang = DRaidFrames:GetLangTab()
	
	lang.SORTTYPE = "排序類型"
	
	lang.OUBR = "外邊框"
	lang.ROSP = "行間距"
	lang.COSP = "欄間距"
	lang.HEWI = "生命值寬度"
	lang.HEHE = "生命值高度"
	lang.POSI = "Power Size"

	lang.GRHO = "水平群組"
	lang.BAUP = "行列向上"
	
	lang.DESI = "減益大小"
	lang.BUSI = "增益大小"

	lang.TETOTY = "Top Text type"
	lang.TECETY = "生命文字類型"

	lang.SHPO = "顯示能量"
	
	lang.DETY = "減益類型"

	lang.DECI = "Decimals"

	lang.OVER = "Overlap"

	lang.OORA = "Out Of Range Alpha"
end