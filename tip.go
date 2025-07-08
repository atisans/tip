package tip

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"slices"
	"time"
)

type item struct {
	ID          int       `json:"id"`
	Task        string    `json:"task"`
	Done        bool      `json:"done"`
	CreatedAt   time.Time `json:"created_at"`
	CompletedAt time.Time `json:"completed_at"`
}

type List []item

func (l *List) Add(task string) {
	t := item{
		ID:          len(*l) + 1,
		Task:        task,
		Done:        false,
		CreatedAt:   time.Now(),
		CompletedAt: time.Time{},
	}

	*l = append(*l, t)
}

func (l *List) Complete(id int) error {
	for i := range *l {
		item := &(*l)[i]

		if item.ID == id {
			item.Done = true
			item.CompletedAt = time.Now()

			return nil
		}
	}

	return fmt.Errorf("Item %d does not exist", id)
}

func (l *List) Delete(id int) error {
	ls := []item(*l)

	newList := slices.DeleteFunc(ls, func(it item) bool {
		return it.ID == id
	})

	if len(newList) == len(*l) {
		return fmt.Errorf("Item %d does not exist", id)
	}

	*l = List(newList)
	return nil
}

func (l *List) Save(filename string) error {
	json, err := json.Marshal(l)
	if err != nil {
		return err
	}

	return os.WriteFile(filename, json, 0644)
}

func (l *List) Get(filename string) error {
	file, err := os.ReadFile(filename)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return nil
		}
		return err
	}

	return json.Unmarshal(file, l)
}
