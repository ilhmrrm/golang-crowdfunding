package payment

import (
	"golang-crowdfunding/user"
	"strconv"

	"github.com/midtrans/midtrans-go"
	"github.com/midtrans/midtrans-go/snap"
)

type service struct {
}

type Service interface {
	GetPaymentURL(transaction Transaction, user user.User) (string, error)
}

func NewService() *service {
	return &service{}
}

func (s *service) GetPaymentURL(transaction Transaction, user user.User) (string, error) {

	midtrans.Environment = midtrans.Sandbox

	var sn = snap.Client{}
	sn.New("SERVER-KEY", midtrans.Environment)

	snapReq := &snap.Request{
		CustomerDetail: &midtrans.CustomerDetails{
			FName: user.Name,
			Email: user.Email,
		},
		TransactionDetails: midtrans.TransactionDetails{
			OrderID:  strconv.Itoa(transaction.ID),
			GrossAmt: int64(transaction.Amount),
		},
	}

	snapRes, err := sn.CreateTransactionUrl(snapReq)
	if err != nil {
		return "", err
	}

	return snapRes, nil
}
