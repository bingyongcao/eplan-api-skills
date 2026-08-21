using Eplan.EplApi.Base;
using Eplan.EplApi.DataModel;
using Eplan.EplApi.DataModel.Graphics;

namespace EplanUtilities
{
    public static class TextUtility
    {
        /// <summary>
        /// create mutiple-lang text
        /// </summary>
        /// <param name="page"></param>
        /// <param name="loc"></param>
        /// <param name="textHeight"></param>
        /// <param name="zh_CN_Content"></param>
        /// <param name="en_US_Content"></param>
        /// <returns></returns>
        public static Text CreateText(
            Page page, 
            PointD loc,
            double textHeight,
            string zh_CN_Content,
            string en_US_Content = "")
        {
            try
            {
                var text = new Text();

                MultiLangString multiText = new MultiLangString();
                multiText.AddString(ISOCode.Language.L_en_US, string.IsNullOrEmpty(en_US_Content)? zh_CN_Content: en_US_Content);
                multiText.AddString(ISOCode.Language.L_zh_CN, zh_CN_Content);

                text.Create(page, multiText, textHeight);
                text.Location = loc;

                return text;
            }
            catch (System.Exception ex)
            {
                new Decider().Decide(
                    EnumDecisionType.eOkDecision,
                    $"{ex.Message}",
                    "Error",
                    EnumDecisionReturn.eOK,
                    EnumDecisionReturn.eOK);
                return null;
            }
        }
    }
}
