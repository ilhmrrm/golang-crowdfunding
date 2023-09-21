package campaign

import "strings"

type CampaignFormatter struct {
	ID                int    `json:"id"`
	UserID            int    `json:"user_id"`
	Name              string `json:"name"`
	ShortDescriptsion string `json:"short_description"`
	ImageURL          string `json:"image_url"`
	GoalAmount        int    `json:"goal_amount"`
	CurrentAmount     int    `json:"current_amount"`
	Slug              string `json:"slug"`
}

type CampaignDetailFormatter struct {
	ID                int      `json:"id"`
	Name              string   `json:"name"`
	ShortDescriptsion string   `json:"short_description"`
	Description       string   `json:"description"`
	ImageURL          string   `json:"image_url"`
	GoalAmount        int      `json"goal_amount"`
	CurrentAmount     int      `json:"current_amount"`
	UserID            int      `json:"user_id"`
	Slug              string   `json:"slug"`
	Perks             []string `json"perks"`
}

func FormatCampaign(campaign Campaign) CampaignFormatter {
	campaignFormatter := CampaignFormatter{}
	campaignFormatter.ID = campaign.ID
	campaignFormatter.UserID = campaign.UserId
	campaignFormatter.Name = campaign.Name
	campaignFormatter.ShortDescriptsion = campaign.ShortDescription
	campaignFormatter.GoalAmount = campaign.GoalAmount
	campaignFormatter.CurrentAmount = campaign.CurrentAmount
	campaignFormatter.Slug = campaign.Slug
	campaignFormatter.ImageURL = ""

	if len(campaign.CampaignImages) > 0 {
		campaignFormatter.ImageURL = campaign.CampaignImages[0].FileName
	}

	return campaignFormatter
}

func FormatCampaigns(campaigns []Campaign) []CampaignFormatter {
	campaignsFormatter := []CampaignFormatter{}

	for _, campaign := range campaigns {
		campaignFormatter := FormatCampaign(campaign)
		campaignsFormatter = append(campaignsFormatter, campaignFormatter)
	}

	return campaignsFormatter
}

func FormatCampaignDetail(campaign Campaign) CampaignDetailFormatter {
	campaignDetailFormatter := CampaignDetailFormatter{}
	campaignDetailFormatter.ID = campaign.ID
	campaignDetailFormatter.Name = campaign.Name
	campaignDetailFormatter.ShortDescriptsion = campaign.ShortDescription
	campaignDetailFormatter.Description = campaign.Description
	campaignDetailFormatter.GoalAmount = campaign.GoalAmount
	campaignDetailFormatter.CurrentAmount = campaign.CurrentAmount
	campaignDetailFormatter.UserID = campaign.UserId
	campaignDetailFormatter.Slug = campaign.Slug
	campaignDetailFormatter.ImageURL = ""

	if len(campaign.CampaignImages) > 0 {
		campaignDetailFormatter.ImageURL = campaign.CampaignImages[0].FileName
	}

	var perks []string

	for _, perk := range strings.Split(campaign.Perks, ",") {
		perks = append(perks, strings.TrimSpace(perk))
	}

	campaignDetailFormatter.Perks = perks

	return campaignDetailFormatter
}
